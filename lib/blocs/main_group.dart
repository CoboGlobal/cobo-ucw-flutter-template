import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ucw_sdk/data.dart' show TSSRequest;
import 'package:cobo_flutter_template/common/config.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/ucw_sdk_init.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';
import 'package:cobo_flutter_template/blocs/vault_info.dart';
import 'package:cobo_flutter_template/data/api.dart';
import 'package:cobo_flutter_template/data/models/index.dart';

final _logger = Logger((MainGroupBloc).toString());

enum MainGroupStatus {
  notStarted,
  readyToCreateMainGroup,
  createMainGroupRequesting,
  createMainGroupRequested,
  mpcProcessing,
  pendingSdkTssRequestsQuerying,
  pendingSdkTssRequestsExisted,
  keyGenSdkApproving,
  keyGenSdkApproved,
  completed,
  failed
}

class MainGroupBloc extends BaseBloc {
  static final MainGroupBloc _instance = MainGroupBloc._internal();
  factory MainGroupBloc.shared() => _instance;
  final ApiService api = ApiService();

  MainGroupBloc._internal() {
    _setupBloc();
  }

  final _mainGroupStatus =
      BehaviorSubject<MainGroupStatus>.seeded(MainGroupStatus.notStarted);
  final _tssRequestId = BehaviorSubject<String?>();
  final _pendingTssRequests = BehaviorSubject<List<TSSRequest>?>();
  final _mainGroupId = BehaviorSubject<String?>();
  bool _isNotDisposed = true; 

  ValueStream<MainGroupStatus> get mainGroupStatus => _mainGroupStatus.stream;
  ValueStream<String?> get tssRequestId => _tssRequestId.stream;
  ValueStream<List<TSSRequest>?> get pendingTssRequests =>
      _pendingTssRequests.stream;
  ValueStream<String?> get mainGroupId => _mainGroupId.stream;

  void _setupBloc() async {
    VaultInfoBloc.shared()
        .vaultStatus
        .where((ev) => ev == VaultStatus.completed)
        .listen((ev) async {
      String mainGroupId =
          VaultInfoBloc.shared().vaultInfo.valueOrNull?.mainGroupId ?? "";
      int mainGroupStatus =
          VaultInfoBloc.shared().vaultInfo.valueOrNull?.status ??
              KeyGroupStatus.unspecified;
      if (mainGroupId.isNotEmpty &&
          (mainGroupStatus == KeyGroupStatus.mainGenerated)) {
        _mainGroupId.add(mainGroupId);
        _mainGroupStatus.add(MainGroupStatus.completed);
        _logger.info(
            'Get generated main group successfully. mainGroupId: $mainGroupId');
      } else if (mainGroupId.isNotEmpty &&
          (mainGroupStatus == KeyGroupStatus.mainGroupCreated)) {
        await getPendingSdkTssRequests();
      } else {
        _mainGroupStatus.add(MainGroupStatus.readyToCreateMainGroup);
      }
    }).cancelBy(disposeBag);
  }

  @override
  void dispose() {
    _isNotDisposed = false;
    super.dispose();
  }

  Future<void> startMainGroupGeneration() async {
    try {
      _logger.info('Start to request main group generation ...');
      _mainGroupStatus.add(MainGroupStatus.createMainGroupRequesting);
      String token = UserLoginBloc.shared().token.value;
      String vaultId =
          VaultInfoBloc.shared().vaultInfo.valueOrNull?.vaultId ?? "";
      String nodeID = UcwSdkInitBloc.shared().nodeId.valueOrNull ?? "";
      String tssRequestId =
          await api.generateMainKeyGroup(token, vaultId, nodeID);
      _tssRequestId.add(tssRequestId);
      _mainGroupStatus.add(MainGroupStatus.createMainGroupRequested);
      _logger.info(
          'Request to create generate main group successfully. tssRequestId: $tssRequestId');
    } catch (e) {
      _mainGroupStatus.add(MainGroupStatus.readyToCreateMainGroup);
      _logger.severe('Request main group generation error occurred: $e');
    }
  }

  Future<void> pollingCheckStatusUntilMpcProcessing() async {
    int pollingCount = 1;
    String token = UserLoginBloc.shared().token.value;
    String vaultId =
        VaultInfoBloc.shared().vaultInfo.valueOrNull?.vaultId ?? "";
    String tssRequestId = _tssRequestId.valueOrNull ?? "";
    assert(tssRequestId.isNotEmpty, "tssRequestId is empty，can't polling");
    while (_isNotDisposed) {
      try {
        await Future.delayed(Duration(
            seconds:
                pollingInterval)); // Interval between each polling attempt
        _logger.info(
            'Start to polling to check the status of the main group generation until it reaches MpcProcessing status...');
        TssRequestInfo tssRequestInfo =
            await api.getTssRequestInfo(token, vaultId, tssRequestId);
        int tssRequestStatus =
            tssRequestInfo.status ?? TssRequestInfoStatus.statusUnspecified;
        if (tssRequestStatus >= TssRequestInfoStatus.statusMpcProcessing) {
          _mainGroupStatus.add(MainGroupStatus.mpcProcessing);
          _logger.info(
              'End polling, now it reaches MpcProcessing status. pollingCount: $pollingCount');
          break;
        }
        if (pollingCount >= pollingMaxTime) {
          _logger.severe(
              'Polling time exceeded the maximum limit before it reaches MpcProcessing. pollingCount: $pollingCount');
          break;
        }
      } catch (e) {
        _logger.severe(
            'Polling to check the status of the main group generation before it reaches MpcProcessing error occurred: $e');
        break;
      } finally {
        pollingCount++;
      }
    }
  }

  Future<void> getPendingSdkTssRequests() async {
    try {
      _logger.info('Start to get pending sdk TSS requests ...');
      _mainGroupStatus.add(MainGroupStatus.pendingSdkTssRequestsQuerying);
      List<TSSRequest>? tssRequestList = await UcwSdkInitBloc.shared()
          .ucwSdk
          .valueOrNull
          ?.listPendingTSSRequests();
      if ((tssRequestList == null) || (tssRequestList.isEmpty)) {
        _pendingTssRequests.add([]);
        _logger.info('No pending sdk TSS request found.');
        _logger.info(
            'Now you can create the main group key. Please click the button in demo to create.');
        _mainGroupStatus.add(MainGroupStatus.readyToCreateMainGroup);
      } else {
        _pendingTssRequests.add(tssRequestList);
        _logger.info(
            'Get pending sdk TSS requests successfully. tssRequestIDList: ${tssRequestList.map((t) => t.tssRequestID)}');
        _logger.info(
            'Now you can approve the existed pending requests. Please click the button in demo to approve.');
        _mainGroupStatus.add(MainGroupStatus.pendingSdkTssRequestsExisted);
      }
    } catch (e) {
      _logger.severe('Get pending sdk TSS requests error occurred: $e');
      _mainGroupStatus.add(MainGroupStatus.pendingSdkTssRequestsQuerying);
    }
  }

  Future<void> approveMainGroupGenerationRequest(int idx) async {
    try {
      _mainGroupStatus.add(MainGroupStatus.keyGenSdkApproving);
      final pendingTssRequests = (_pendingTssRequests.valueOrNull ?? []);
      List<String> tssRequestIDs = [pendingTssRequests[idx].tssRequestID];
      _logger.info(
          'Start to approve TSS request with sdk approve call. tssRequestIDs: $tssRequestIDs ... ');
      await UcwSdkInitBloc.shared()
          .ucwSdk
          .valueOrNull
          ?.approveTSSRequests(tssRequestIDs);
      _mainGroupStatus.add(MainGroupStatus.keyGenSdkApproved);
      _logger.info('Approve TSS request successfully. ');
    } catch (e) {
      _mainGroupStatus.add(MainGroupStatus.mpcProcessing);
      _logger.severe('Approve TSS request error occurred: $e');
    }
  }

  // PS: Need to implement the polling logic to check the status of the main group generation request.
  Future<void> pollingCheckStatusUntilComplete(int idx) async {
    int pollingCount = 1;
    String token = UserLoginBloc.shared().token.value;
    String vaultId =
        VaultInfoBloc.shared().vaultInfo.valueOrNull?.vaultId ?? "";
    final pendingTssRequests = (_pendingTssRequests.valueOrNull ?? []);
    String tssRequestId = pendingTssRequests[idx].tssRequestID;
    while (_isNotDisposed) {
      try {
        await Future.delayed(Duration(
            seconds:
                pollingInterval)); // Interval between each polling attempt
        _logger.info(
            'Start to polling to check the status of the main group generation by backend api until it reaches complete status...');

        TssRequestInfo tssRequestInfo =
            await api.getTssRequestInfo(token, vaultId, tssRequestId);
        int tssRequestStatus =
            tssRequestInfo.status ?? TssRequestInfoStatus.statusUnspecified;
        if (checkIsEnd(tssRequestStatus)) {
          if (checkIsCompleted(tssRequestStatus)) {
            _mainGroupStatus.add(MainGroupStatus.completed);
            _mainGroupId.add(tssRequestInfo.targetGroupId);
            _logger.info(
                'the main group generation is successful. status: $tssRequestStatus. pollingCount: $pollingCount');
          } else {
            _mainGroupStatus.add(MainGroupStatus.failed);
            _logger.info(
                'the main group generation is failed. status: $tssRequestStatus. pollingCount: $pollingCount');
          }
          break;
        } 
        if (pollingCount >= pollingMaxTime) {
          _logger.severe(
              'Polling time exceeded the maximum limit before it reaches complete. pollingCount: $pollingCount');
          break;
        }
        _logger.info(
            'End to polling to check the status of the main group generation by backend api. Status: $tssRequestStatus.');
        
      } catch (e) {
        _logger.severe(
            'Polling to check the status of the main group generation before it reaches complete. error occurred: $e');
      } finally {
        pollingCount++;
      }
    }
  }

  bool checkIsCompleted(int tssRequestInfoStatus) {
    return tssRequestInfoStatus == TssRequestInfoStatus.statusSuccess;
  }

  bool checkIsEnd(int tssRequestInfoStatus) {
    return [
      TssRequestInfoStatus.statusSuccess,
      TssRequestInfoStatus.statusKeyGeneratingFailed
    ].contains(tssRequestInfoStatus);
  }
}
