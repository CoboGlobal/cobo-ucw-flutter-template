import 'package:flutter/material.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/steps/2_wallet/1_create_wallet_Item.dart';
import 'package:cobo_flutter_template/steps/2_wallet/2_create_address_Item.dart';

class WalletStep extends StatefulWidget {
  const WalletStep({super.key});

  @override
  State<WalletStep> createState() => _WalletStepState();
}

class _WalletStepState extends DisposableState<WalletStep> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const StepSection(
        order: 2,
        title: 'Create a wallet and an address',
        desc:
            'This section details the sequence of operations involved in creating a wallet and generating an address within your User-Controlled Wallets.',
        child: Column(
          children: [
            CreateWalletItem(),
            CreateAddressItem(),
          ],
        ));
  }
}
