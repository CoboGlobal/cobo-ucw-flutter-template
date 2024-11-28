import 'package:cobo_flutter_template/blocs/vault_info.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/main_group.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';
import 'package:cobo_flutter_template/data/api.dart';
import 'package:cobo_flutter_template/data/models/index.dart';


final _logger = Logger((WalletInfoBloc).toString());

enum WalletStatus { notStarted, inProgress, completed }

class WalletInfoBloc extends BaseBloc {
  static final WalletInfoBloc _instance = WalletInfoBloc._internal();
  factory WalletInfoBloc.shared() => _instance;
  final ApiService api = ApiService();

  WalletInfoBloc._internal() {
    _setupBloc();
  }

  final _walletInfo = BehaviorSubject<Wallet?>();
  final _walletStatus =
      BehaviorSubject<WalletStatus>.seeded(WalletStatus.notStarted);

  ValueStream<Wallet?> get walletInfo => _walletInfo.stream;
  ValueStream<WalletStatus?> get walletStatus => _walletStatus.stream;

  void _setupBloc() async {
    MainGroupBloc.shared()
        .mainGroupStatus
        .where((ev) => ev == MainGroupStatus.completed)
        .listen((userInfo) {
      final walletInfo = UserLoginBloc.shared().userInfo.valueOrNull?.wallet;
      if (walletInfo != null) {
        _walletInfo.add(walletInfo);
        _walletStatus.add(WalletStatus.completed);
        _logger.info(
            'Wallet info already exists. walletId: ${walletInfo.walletId}');
      }
    }).cancelBy(disposeBag);
    MainGroupBloc.shared()
        .mainGroupStatus
        .where((evt) => evt == MainGroupStatus.completed)
        .listen((status) {
      if (_walletInfo.valueOrNull == null) {
        createWallet();
      } 
    }).cancelBy(disposeBag);
  }

  Future<void> createWallet() async {
    try {
      if (loading.value) {
        return;
      }
      setLoading(true);
      _logger.info('Create new wallet started.');
      _walletStatus.add(WalletStatus.inProgress);
      final token = UserLoginBloc.shared().token.value;
      final vaultId =
          VaultInfoBloc.shared().vaultInfo.valueOrNull?.vaultId ?? "";
      Wallet walletInfo =
          await api.createWallet(token, vaultId, _generateWalletName());
      _walletStatus.add(WalletStatus.completed);
      _walletInfo.add(walletInfo);
      _logger.info(
          'Create new wallet successful. walletId: ${walletInfo.walletId}');
    } catch (e) {
      _walletStatus.add(WalletStatus.notStarted);
      _logger.severe('Create new wallet error occurred: $e');
    } finally {
      setLoading(false);
    }
  }

  String _generateWalletName() {
    final now = DateTime.now();
    final formattedDate =
        "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}";
    return "walletNameTest_$formattedDate";
  }
}
