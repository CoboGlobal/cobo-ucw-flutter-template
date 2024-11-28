import 'package:flutter/material.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import '1_user_login_Item.dart';
import '2_init_sdk_Item.dart';
import '3_create_vault_Item.dart';
import '4_create_main_group_Item.dart';

class SetupStep extends StatefulWidget {
  const SetupStep({super.key});

  @override
  State<SetupStep> createState() => _SetupStepState();
}

class _SetupStepState extends DisposableState<SetupStep> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const StepSection(
        title: 'Complete the initial setup',
        desc:
            'This section details the sequence of operations involved in setting up some steps before use the User-Controlled Wallets.',
        child: Column(
          children: [
            UserLoginItem(),
            InitSDKItem(),
            CreateVaultItem(),
            CreateMainGroupItem()
          ],
        ));
  }
}
