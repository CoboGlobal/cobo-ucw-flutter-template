import 'package:cobo_flutter_template/steps/4_backup_restore/1_backup_item.dart';
import 'package:flutter/material.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';

class BackupRestoreStep extends StatefulWidget {
  const BackupRestoreStep({super.key});

  @override
  State<BackupRestoreStep> createState() => _WalletStepState();
}

class _WalletStepState extends DisposableState<BackupRestoreStep> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const StepSection(
        order: 4,
        title: 'Backup and restore',
        desc:
            'This section describes the process of exporting encrypted Secrets from one instance of the UCW SDK in a Client App, saving it to an iCloud server, and subsequently importing the Secrets into another instance of the UCW SDK in a different Client App.',
        child: Column(
          children: [BackupItem()],
        ));
  }
}
