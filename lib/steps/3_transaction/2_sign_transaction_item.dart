import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:ucw_sdk/data.dart' show Transaction;
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/transaction.dart';
import 'package:cobo_flutter_template/blocs/wallet_address.dart';

final _logger = Logger((SignTransactionItem).toString());

class SignTransactionItem extends StatefulWidget {
  const SignTransactionItem({super.key});

  @override
  State<SignTransactionItem> createState() => _SignTransactionItemState();
}

class _SignTransactionItemState extends DisposableState<SignTransactionItem> {
  final _transactionSignBlocMap =
      BehaviorSubject<Map<String, TransactionSignBloc>>.seeded({});
  final _isPendingTxQuerying = BehaviorSubject<bool>.seeded(false);    

  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {
    WalletAddressBloc.shared()
        .walletAddressStatus
        .where((evt) => evt == WalletAddressStatus.completed)
        .listen((status) async {
      reload();
    }).cancelBy(disposeBag);
  }

  Future<void> reload() async {
    try {
      if (_isPendingTxQuerying.value) {
        return;
      }
      _isPendingTxQuerying.add(true);
      List<Transaction> transactions =
        await TransactionSignBloc.getPendingSdkTransactions();
      bool isAdded = false;
      final transactionSignBlocMap = _transactionSignBlocMap.valueOrNull ?? {};
      for (var tx in transactions) {
        if (!transactionSignBlocMap.containsKey(tx.transactionID)) {
          final transactionSignBloc = TransactionSignBloc(
              tx.transactionID, TokenTransferStatus.txCreated);
          await transactionSignBloc.getTransactionInfo(tx.transactionID);
          transactionSignBlocMap[tx.transactionID] = transactionSignBloc;
          isAdded = true;
        }
      }
      if (isAdded) {
        _logger.info(
            'Add new pending transaction to list. now transaction id list: ${transactionSignBlocMap.keys.toList()}');
      }
      _transactionSignBlocMap.add(transactionSignBlocMap);
      // transactionSignBlocMap.forEach(
      //     (String txID, TransactionSignBloc transactionSignBloc) async {
      //   await transactionSignBloc.getTransactionInfo(txID);
      // });
    } catch (e) {
      _logger.severe('Reload pending transaction list error occurred: $e');
    } finally {
      _isPendingTxQuerying.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _transactionSignBlocMap,
        initialData: {},
        builder: (context, snapshot) {
          final transactionSignBlocMap = snapshot.data;
          final transactionSignBlocList = transactionSignBlocMap?.values
                  .toList()
                  .cast<TransactionSignBloc>() ??
              [];
          String? desc;
          Widget? child;
          if (transactionSignBlocList.isEmpty) {
            child = _buildEmptySection();
          }
          return InfoSection(
              title: '2. List pending transactions to sign',
              desc: desc ?? "",
              child: child ??
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildPendingTransactionSections(
                        transactionSignBlocList),
                  ));
        });
  }

  List<Widget> _buildPendingTransactionSections(
      List<TransactionSignBloc> transactionSignBlocList) {
    final items = <Widget>[_buildRefreshButton()];
    for (var transactionSignBloc in transactionSignBlocList) {
      final index = transactionSignBlocList.indexOf(transactionSignBloc);
      items.addAll([
        const SizedBox(height: 12),
        _buildPendingTransactionSection(transactionSignBloc, index),
      ]);
    }
    return items;
  }

  Widget _buildPendingTransactionSection(
      TransactionSignBloc transactionSignBloc, int index) {
    return StreamBuilder(
        stream: transactionSignBloc.transactionStatus,
        initialData: TokenTransferStatus.notStarted,
        builder: (context, snapshot) {
          TokenTransferStatus status =
              snapshot.data ?? TokenTransferStatus.notStarted;
          final items = <Widget>[];
          if (!transactionSignBloc.transaction.hasValue) {
            return SizedBox.shrink();
          }
          final transaction = transactionSignBloc.transaction.value;
          switch (status) {
            case TokenTransferStatus.notStarted:
            case TokenTransferStatus.readyToCreateTx:
            case TokenTransferStatus.txCreating:
            case TokenTransferStatus.txCreated:
              items.addAll(
                  _buildPendingTransactionsToApproveItem(transaction, index));
              break;
            case TokenTransferStatus.transactionApproving:
              items.addAll(_buildPendingTransactionsToApproveItem(
                  transaction, index,
                  isApproving: true));
              break;
            case TokenTransferStatus.transactionApproved:
            case TokenTransferStatus.completed:
              items.addAll(
                  _buildPendingTransactionsApprovedItem(transaction, index));
              break;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          );
        });
  }

  List<Widget> _buildPendingTransactionsToApproveItem(
      Transaction pendingTransaction, int index,
      {bool isApproving = false}) {
    final items = <Widget>[];
    Widget? loadingIcon;
    if (isApproving) {
      loadingIcon = TDLoading(
        size: TDLoadingSize.small,
        icon: TDLoadingIcon.circle,
        iconColor: TDTheme.of(context).whiteColor1,
      );
    }
    items.addAll([
      ContextItem(
          title: "${index + 1}. Transaction ID: ",
          child: Text(
            pendingTransaction.transactionID,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: TDTheme.of(context).fontGyColor1, fontSize: 11),
          )),
      const SizedBox(height: 8),
      TDButton(
          text: 'approve transaction',
          theme: TDButtonTheme.primary,
          size: TDButtonSize.extraSmall,
          iconWidget: loadingIcon ?? SizedBox.shrink(),
          onTap: () {
            _handleApproveTx(pendingTransaction.transactionID);
          }),
    ]);
    return items;
  }

  List<Widget> _buildPendingTransactionsApprovedItem(
      Transaction transaction, int index) {
    final items = <Widget>[];
    items.addAll([
      ContextItem(
          title: "${index + 1}. Transaction ID ",
          child: Text(
            transaction.transactionID,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: TDTheme.of(context).fontGyColor1, fontSize: 11),
          )),
      const SizedBox(height: 8),
      ContextItem(title: "Signature status:", info: transaction.status.name)
    ]);
    return items;
  }

  Future<void> _handleApproveTx(String txID) async {
    if (_transactionSignBlocMap.hasValue) {
      final transactionSignBloc = _transactionSignBlocMap.value[txID];
      await transactionSignBloc?.approvePendingTransaction();
      await transactionSignBloc?.pollingCheckStatusUntilComplete();
    }
  }

  Widget? _buildEmptySection() {
    String info = "No pending transactions to sign. ";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TDText(
          info,
          maxLines: 2,
          font: TDTheme.of(context).fontBodyMedium,
          textColor: TDTheme.of(context).fontGyColor3,
        ),
        const SizedBox(height: 8),
        _buildRefreshButton()
      ],
    );
  }

  Widget _buildRefreshButton() {
    return StreamBuilder(
        stream: _isPendingTxQuerying.stream,
        initialData: false,
        builder: (context, snapshot) {
          Widget? loadItem;
          final isPendingTxQuerying = snapshot.data ?? false;
          if (isPendingTxQuerying) {
            loadItem = const TDLoading(
              size: TDLoadingSize.small,
              icon: TDLoadingIcon.circle,
            );
          }
          return GestureDetector(
            onTap: () {
              reload();
            },
            child: Row(
              children: [
                loadItem ??
                    Icon(TDIcons.refresh,
                        size: 16, color: TDTheme.of(context).brandNormalColor),
                const SizedBox(width: 4),
                TDText(
                  'Click here to refresh list',
                  font: TDTheme.of(context).fontBodyMedium,
                  textColor: TDTheme.of(context).brandNormalColor,
                ),
              ],
            ),
          );
        });
  }
}
