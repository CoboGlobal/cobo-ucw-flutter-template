import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ucw_sdk/data.dart' show Transaction, Status;
import 'package:cobo_flutter_template/common/config.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';
import 'package:cobo_flutter_template/blocs/wallet_info.dart';
import 'package:cobo_flutter_template/blocs/ucw_sdk_init.dart';
import 'package:cobo_flutter_template/blocs/wallet_address.dart';
import 'package:cobo_flutter_template/data/api.dart';


final _logger = Logger((TransactionSignBloc).toString());
final demoChain = "SETH";
final demoTokenId = "SETH";
final demoToAddress = "0x8FF1E41fb608034ABA75C8Fd8B29e17FD25cEb4c";

enum TokenTransferStatus {
  notStarted,
  readyToCreateTx,
  txCreating,
  txCreated,
  transactionApproving,
  transactionApproved,
  completed
}

class TransactionCreateBloc extends BaseBloc {
  static final TransactionCreateBloc _instance =
      TransactionCreateBloc._internal();
  factory TransactionCreateBloc.shared() => _instance;
  final ApiService api = ApiService();

  TransactionCreateBloc._internal() {
    _setupBloc();
  }

  final _transactionStatus = BehaviorSubject<TokenTransferStatus>.seeded(
      TokenTransferStatus.notStarted);
  final _transactionId = BehaviorSubject<String>();

  ValueStream<TokenTransferStatus> get transactionStatus =>
      _transactionStatus.stream;
  ValueStream<String> get transactionId => _transactionId.stream;

  void _setupBloc() async {
    WalletAddressBloc.shared()
        .walletAddressStatus
        .where((evt) => evt == WalletAddressStatus.completed)
        .listen((status) async {
      _transactionStatus.add(TokenTransferStatus.readyToCreateTx);
    }).cancelBy(disposeBag);
  }

  void changeStatus(TokenTransferStatus status) {
    _transactionStatus.add(status);
  }

  // Create transaction
  Future<String?> createTransaction(String amount, String toAddress) async {
    try {
      if (TokenTransferStatus.txCreating == _transactionStatus.value) {
        return null;
      }
      _logger.info('Create transaction started...');
      _transactionStatus.add(TokenTransferStatus.txCreating);
      final token = UserLoginBloc.shared().token.value;
      final walletId =
          WalletInfoBloc.shared().walletInfo.valueOrNull?.walletId ?? "";
      String fromAddress =
          WalletAddressBloc.shared().walletAddress.valueOrNull?.address ?? "";
      final txParams = jsonEncode({
        "from": fromAddress,
        "to": toAddress,
        "amount": amount,
        "token_id": demoTokenId,
        "chain": demoChain,
        "type": 1,
        "wallet_id": walletId,
        "fee": {
          "gas_price": "14915509849",
          "gas_limit": "21000",
          "level": 2,
          "token_id": demoTokenId,
        }
      });
      String txId = await api.createTransaction(token, walletId, txParams);
      _transactionId.add(txId);
      _transactionStatus.add(TokenTransferStatus.txCreated);
      _logger.info('Create transaction successful. txId: $txId');
      _logger
          .info('Now you can click the refresh the transaction list in demo.');
      return txId;
    } catch (e) {
      _transactionStatus.add(TokenTransferStatus.readyToCreateTx);
      _logger.severe('Create transaction error occurred: $e');
    }
    return null;
  }
}

class TransactionSignBloc extends BaseBloc {
  String txID;
  final ApiService api = ApiService();

  TransactionSignBloc(this.txID, TokenTransferStatus? status) {
    _setupBloc();
    _transactionStatus.add(status ?? TokenTransferStatus.notStarted);
  }

  final _transactionStatus = BehaviorSubject<TokenTransferStatus>.seeded(
      TokenTransferStatus.notStarted);
  final _transaction = BehaviorSubject<Transaction>();
  bool _isNotDisposed = true; // 轮训介绍标识

  ValueStream<TokenTransferStatus> get transactionStatus =>
      _transactionStatus.stream;
  ValueStream<Transaction> get transaction => _transaction.stream;

  void _setupBloc() async {}

  @override
  void dispose() {
    _isNotDisposed = false;
    super.dispose();
  }

  // Get pending sdk transactions
  static Future<List<Transaction>> getPendingSdkTransactions() async {
    try {
      _logger.info('Start to get pending sdk transactions by sdk api ...');
      List<Transaction> transactionList = await UcwSdkInitBloc.shared()
              .ucwSdk
              .valueOrNull
              ?.listPendingTransactions() ??
          [];
      if (transactionList.isEmpty) {
        _logger.info('No pending sdk transactions found.');
        return [];
      }
      _logger.info(
          'Get pending sdk transactions by sdk api successfully. transactionIDList: ${transactionList.map((t) => t.transactionID)}');
      return transactionList;
    } catch (e) {
      _logger
          .severe('Get pending sdk transactions by sdk api error occurred: $e');
    }
    return [];
  }

  // Get transaction info
  Future<void> getTransactionInfo(String txID) async {
    try {
      _logger.info('Start to get the transaction info by sdk call api ...');
      final transactionInfos = (await UcwSdkInitBloc.shared()
              .ucwSdk
              .valueOrNull
              ?.getTransactions([txID])) ??
          [];
      if (transactionInfos.isEmpty) {
        throw Exception('No transaction info found');
      }
      final Transaction tx = transactionInfos[0];
      _transaction.add(tx);
      _logger.info(
          'End to get the transaction info by sdk call api, tx: ${tx.toJson()} ');
    } catch (e) {
      _logger.severe(
          'Get the transaction info by sdk call api error occurred: $e');
    }
  }

  Future<void> approvePendingTransaction() async {
    try {
      _logger.info('Start to approve transaction with sdk approve call ...');
      _transactionStatus.add(TokenTransferStatus.transactionApproving);
      List<String>? transactionIDs = [txID];
      await UcwSdkInitBloc.shared()
          .ucwSdk
          .valueOrNull
          ?.approveTransactions(transactionIDs);
      _transactionStatus.add(TokenTransferStatus.transactionApproved);
      _logger.info('Approve transaction successfully.');
    } catch (e) {
      _logger.severe('Approve transaction error occurred: $e');
    }
  }

  Future<void> pollingCheckStatusUntilComplete() async {
    int pollingCount = 1;
    while (_isNotDisposed) {
      try {
        await Future.delayed(Duration(
            seconds: pollingInterval)); // Interval between each polling attempt
        _logger.info(
            'Start to polling to check the status of the transaction by sdk call api until it reaches complete status...');
        final transactionInfos = (await UcwSdkInitBloc.shared()
                .ucwSdk
                .valueOrNull
                ?.getTransactions([txID])) ??
            [];
        if (transactionInfos.isEmpty) {
          throw Exception('No transaction info found');
        }
        final Transaction tx = transactionInfos[0];
        Status transactionStatus = tx.status;
        _transaction.add(tx);
        if (transactionStatus == Status.completed) {
          _transactionStatus.add(TokenTransferStatus.completed);
          _logger.info(
              'the transaction is successful. pollingCount: $pollingCount');
          break;
        }
        if (pollingCount >= pollingMaxTime) {
          _logger.severe(
              'Polling time exceeded the maximum limit before it reaches complete. pollingCount: $pollingCount');
          break;
        }
        _logger.info(
            'End to polling to check the status of the transaction by sdk call api, tx: ${tx.toJson()} ');
      } catch (e) {
        _logger.severe(
            'Polling to check the status of the transaction before it reaches complete error occurred: $e');
        break;
      } finally {
        pollingCount++;
      }
    }
  }
}
