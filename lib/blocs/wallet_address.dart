import 'package:cobo_flutter_template/common/config.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';
import 'package:cobo_flutter_template/blocs/wallet_info.dart';
import 'package:cobo_flutter_template/data/api.dart';
import 'package:cobo_flutter_template/data/models/index.dart';

final _logger = Logger((WalletAddressBloc).toString());
final demoChain = "SETH";
final demoTokenId = "SETH";

enum WalletAddressStatus {
  notStarted,
  tokenAddressCreating,
  tokenAddressCreated,
  tokenAddressInfoQuerying,
  tokenAddressInfoQueryed,
  completed
}

class WalletAddressBloc extends BaseBloc {
  static final WalletAddressBloc _instance = WalletAddressBloc._internal();
  factory WalletAddressBloc.shared() => _instance;
  final ApiService api = ApiService();

  WalletAddressBloc._internal() {
    _setupBloc();
  }

  final _walletAddressStatus = BehaviorSubject<WalletAddressStatus>.seeded(
      WalletAddressStatus.notStarted);
  final _walletAddress = BehaviorSubject<WalletAddress?>();
  final _tokenInfo = BehaviorSubject<TokenInfo?>();

  ValueStream<WalletAddressStatus?> get walletAddressStatus =>
      _walletAddressStatus.stream;
  ValueStream<WalletAddress?> get walletAddress => _walletAddress.stream;
  ValueStream<TokenInfo?> get tokenInfo => _tokenInfo.stream;

  void _setupBloc() async {
    WalletInfoBloc.shared()
        .walletStatus
        .where((evt) => evt == WalletStatus.completed)
        .listen((status) async {
      bool? hasTokenAddress = await getTokenAddressInfo();
      bool isCreated = false;
      if (hasTokenAddress != null && !hasTokenAddress) {
        isCreated = await createWalletAddress();
      } else if (hasTokenAddress != null && hasTokenAddress) {
        isCreated = true;
      }
      if (isCreated) {
        pollingTokenAddressInfo();
      }
      _walletAddressStatus.add(WalletAddressStatus.completed);
    }).cancelBy(disposeBag);
  }

  /// Creates a new wallet address for the SETH chain.
  Future<bool> createWalletAddress() async {
    try {
      if (loading.value) {
        return false;
      }
      setLoading(true);
      _logger.info('Create new wallet address started.');
      _walletAddressStatus.add(WalletAddressStatus.tokenAddressCreating);
      final token = UserLoginBloc.shared().token.value;
      final walletId =
          WalletInfoBloc.shared().walletInfo.valueOrNull?.walletId ?? "";
      WalletAddress walletAddress =
          await api.createWalletAddress(token, walletId, demoChain);
      _walletAddress.add(walletAddress);
      _walletAddressStatus.add(WalletAddressStatus.tokenAddressCreated);
      _logger.info(
          'Create new wallet address successful. address: ${walletAddress.address}');
    } catch (e) {
      _walletAddressStatus.add(WalletAddressStatus.notStarted);
      _logger.severe('Create new wallet address error occurred: $e');
      return false;
    } finally {
      setLoading(false);
    }
    return true;
  }

  /// Retrieves wallet address information for the demo SETH chain.
  Future<bool?> getTokenAddressInfo() async {
    try {
      if (loading.value) {
        return null;
      }
      setLoading(true);
      _walletAddressStatus.add(WalletAddressStatus.tokenAddressInfoQuerying);
      _logger.info('Get token address info started.');
      final token = UserLoginBloc.shared().token.value;
      final walletId =
          WalletInfoBloc.shared().walletInfo.valueOrNull?.walletId ?? "";
      TokenAddressInfo tokenAddressInfo =
          await api.getTokenAddressInfo(token, walletId, demoTokenId);
      _walletAddressStatus.add(WalletAddressStatus.tokenAddressInfoQueryed);
      bool hasTokenAddress = tokenAddressInfo.addresses.isNotEmpty;
      if (hasTokenAddress) {
        _walletAddress.add(tokenAddressInfo.addresses.first);
        _tokenInfo.add(tokenAddressInfo.token);
        _logger.info(
            'Get token address info successful. First address: ${tokenAddressInfo.addresses.first.toJson()}, token info: ${tokenAddressInfo.token.toJson()}');
      } else {
        _logger.info(
            'Get token address info successful. but no existed address info');
      }
      return hasTokenAddress;
    } catch (e) {
      _walletAddressStatus.add(WalletAddressStatus.notStarted);
      _logger.severe('Get token address info error occurred: $e');
    } finally {
      setLoading(false);
    }
    return null;
  }

  // Periodically fetches and updates token balance information.
  Future<void> pollingTokenAddressInfo() async {
    while (true) {
      await Future.delayed(Duration(seconds: pollingInterval * 5));
      await getTokenAddressInfo();
    }
  }
}
