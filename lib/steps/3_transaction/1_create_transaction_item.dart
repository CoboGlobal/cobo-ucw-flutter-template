import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/wallet_address.dart';
import 'package:cobo_flutter_template/blocs/transaction.dart';

class CreateTranferTxItem extends StatefulWidget {
  const CreateTranferTxItem({super.key});

  @override
  State<CreateTranferTxItem> createState() => _CreateTranferTxItemState();
}

class _CreateTranferTxItemState extends DisposableState<CreateTranferTxItem> {
  final TextEditingController _toAddressController = TextEditingController();
  final TextEditingController _amountAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {
    _toAddressController.text = demoToAddress;
    _amountAddressController.text = "0.0000101";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: TransactionCreateBloc.shared().transactionStatus.distinct(),
        initialData: TokenTransferStatus.notStarted,
        builder: (context, snapshot) {
          TokenTransferStatus status =
              snapshot.data ?? TokenTransferStatus.notStarted;
          final items = <Widget>[];
          String desc = '';
          switch (status) {
            case TokenTransferStatus.notStarted:
              desc = "Not started";
              break;
            case TokenTransferStatus.readyToCreateTx:
              desc = "Demonstrate a Sepolia token transfer";
              items.addAll(_buildTokenTransferItems(false));
              break;
            case TokenTransferStatus.txCreating:
              desc = "Demonstrate a Sepolia token transfer";
              items.addAll(_buildTokenTransferItems(true));
              break;
            case TokenTransferStatus.txCreated:
              desc =
                  "The Sepolia token transfer transaction is created. So now you can click the refresh the transaction list in the next step for transaction signature.";
              items.addAll([
                _buildTxFormCreateLink(),
                ContextItem(
                  title: "Transactin ID",
                  info:
                      TransactionCreateBloc.shared().transactionId.valueOrNull,
                )
              ]);
              break;
            case TokenTransferStatus.transactionApproving:
            case TokenTransferStatus.transactionApproved:
            case TokenTransferStatus.completed:
              break;
          }
          return InfoSection(
              title: '1. Create a transaction',
              desc: desc,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items));
        });
  }

  List<Widget> _buildTokenTransferItems(bool isSubmitting) {
    String fromAddress =
        WalletAddressBloc.shared().walletAddress.valueOrNull?.address ?? "";
    Widget? submitBtnItem;
    if (isSubmitting) {
      submitBtnItem = TDButton(
          text: 'Submitting',
          size: TDButtonSize.extraSmall,
          theme: TDButtonTheme.primary,
          iconWidget: TDLoading(
            size: TDLoadingSize.small,
            icon: TDLoadingIcon.circle,
            iconColor: TDTheme.of(context).whiteColor1,
          ));
    }
    final items = <Widget>[
      ContextItem(
        title: "From address",
        child: Text(
          fromAddress,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style:
              TextStyle(color: TDTheme.of(context).fontGyColor1, fontSize: 11),
        ),
      ),
      SizedBox(height: 4),
      ContextItem(
        title: "To address",
        child: TDInput(
          maxLines: 2,
          contentPadding: EdgeInsets.all(4),
          controller: _toAddressController,
          hintText: 'Input received address',
          hintTextStyle:
              TextStyle(color: TDTheme.of(context).fontGyColor4, fontSize: 11),
          textStyle:
              TextStyle(color: TDTheme.of(context).fontGyColor1, fontSize: 11),
          clearIconSize: 12,
          needClear: false,
        ),
      ),
      SizedBox(height: 4),
      ContextItem(
        title: "Amount",
        child: Row(
          children: [
            Flexible(
                child: TDInput(
              contentPadding: EdgeInsets.all(4),
              controller: _amountAddressController,
              hintText: 'Input token amount',
              hintTextStyle: TextStyle(
                  color: TDTheme.of(context).fontGyColor4, fontSize: 11),
              textStyle:
                  TextStyle(
                  color: TDTheme.of(context).fontGyColor1, fontSize: 11),
              clearIconSize: 12,
              needClear: false,
            )),
            Text("SETH",
                style: TextStyle(
                    color: TDTheme.of(context).fontGyColor2, fontSize: 11))
          ],
        ),
      ),
      SizedBox(height: 12),
      submitBtnItem ??
          TDButton(
            text: 'Submit',
            size: TDButtonSize.extraSmall,
            theme: TDButtonTheme.primary,
            onTap: () async {
              final amount = _amountAddressController.text;
              final toAddress = _toAddressController.text;
              if (amount.isEmpty ||
                  !RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(amount)) {
                TDToast.showText('Invalid amount: $amount', context: context);
                return;
              }
              if (toAddress.isEmpty ||
                  !RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(toAddress)) {
                TDToast.showText('Invalid To Address: $toAddress',
                    context: context);
                return;
              }
              final balance = double.parse(
                  WalletAddressBloc.shared().tokenInfo.valueOrNull?.balance ??
                      "0");
              final amountbalance = double.parse(amount);
              if (amountbalance >= balance) {
                TDToast.showText('Insufficient balance', context: context);
                return;
              }
              await TransactionCreateBloc.shared().createTransaction(
                  amount, toAddress);
              // await TransactionCreateBloc.shared().getTransactionInfo();
            },
          )
    ];
    return items;
  }

  Widget _buildTxFormCreateLink() {
    return GestureDetector(
      onTap: () {
        TransactionCreateBloc.shared()
            .changeStatus(TokenTransferStatus.readyToCreateTx);
      },
      child: Row(
        children: [
          Icon(TDIcons.login,
              size: 16, color: TDTheme.of(context).brandNormalColor),
          const SizedBox(width: 4),
          TDText(
            'Back to create transaction form',
            font: TDTheme.of(context).fontBodyMedium,
            textColor: TDTheme.of(context).brandNormalColor,
          ),
        ],
      ),
    );
  }
}
