import 'package:flutter/material.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/steps/3_transaction/1_create_transaction_item.dart';
import 'package:cobo_flutter_template/steps/3_transaction/2_sign_transaction_item.dart';

class TransactionStep extends StatefulWidget {
  const TransactionStep({super.key});

  @override
  State<TransactionStep> createState() => _WalletStepState();
}

class _WalletStepState extends DisposableState<TransactionStep> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const StepSection(
        order: 3,
        title: 'Create a transaction',
        desc:
            'This section details the process of estimating transaction fees, submitting a transaction, and participating in the signing process for a transaction in your User-Controlled Wallets.',
        child: Column(
          children: [CreateTranferTxItem(), SignTransactionItem()],
        ));
  }
}
