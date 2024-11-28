import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/ucw_sdk_init.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';
import 'package:cobo_flutter_template/data/api.dart';
import 'package:cobo_flutter_template/data/models/index.dart';

final _logger = Logger((VaultInfoBloc).toString());

enum VaultStatus { notStarted, inProgress, completed }

class VaultInfoBloc extends BaseBloc {
  static final VaultInfoBloc _instance = VaultInfoBloc._internal();
  factory VaultInfoBloc.shared() => _instance;
  final ApiService api = ApiService();

  VaultInfoBloc._internal() {
    _setupBloc();
  }

  final _vaultInfo = BehaviorSubject<Vault?>();
  final _vaultStatus =
      BehaviorSubject<VaultStatus>.seeded(VaultStatus.notStarted);
  final _userLoginBloc = UserLoginBloc.shared();

  ValueStream<Vault?> get vaultInfo => _vaultInfo.stream;
  ValueStream<VaultStatus?> get vaultStatus => _vaultStatus.stream;

  void _setupBloc() async {
    UcwSdkInitBloc.shared()
        .nodeStatus
        .where((ev) => ev == NodeStatus.completed)
        .listen((ev) async {
      final vaultInfo = UserLoginBloc.shared().userInfo.valueOrNull?.vault;
      if (vaultInfo == null) {
        initVaultInfo();
      } else {
        _vaultInfo.add(vaultInfo);
        _vaultStatus.add(VaultStatus.completed);
      }
    }).cancelBy(disposeBag);
  }

  Future<void> initVaultInfo() async {
    try {
      if (loading.value) {
        return;
      }
      setLoading(true);
      _logger.info('Initilize new vault started.');
      _vaultStatus.add(VaultStatus.inProgress);
      final token = _userLoginBloc.token.value;
      Vault vaultInfo = await api.initializeVault(token);
      _vaultStatus.add(VaultStatus.completed);
      _vaultInfo.add(vaultInfo);
      _logger.info('Initilize vault successful. vaultId: ${vaultInfo.vaultId}');
    } catch (e) {
      _vaultStatus.add(VaultStatus.notStarted);
      _logger.severe('Initilize vault error occurred: $e');
    } finally {
      setLoading(false);
    }
  }
}
