import 'package:cobo_flutter_template/blocs/backup.dart';
import 'package:flutter/material.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class BackupItem extends StatefulWidget {
  const BackupItem({super.key});

  @override
  State<BackupItem> createState() => _BackupItemState();
}

class _BackupItemState extends DisposableState<BackupItem> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: BackupBloc.shared().status,
        initialData: BackupStatus.notStarted,
        builder: (context, snapshot) {
          BackupStatus status = snapshot.data ?? BackupStatus.notStarted;
          final items = <Widget>[];
          String desc = '';
          switch (status) {
            case BackupStatus.notStarted:
              desc = "Not started";
              break;
            case BackupStatus.readyToExport:
              desc =
                  "Now you can backup your secrets passphrase-encrypted json file of UCW Tss Node";
              items.add(TDButton(
                  text: 'start',
                  theme: TDButtonTheme.primary,
                  size: TDButtonSize.extraSmall,
                  onTap: _handleBackup));
            case BackupStatus.secretsExporting:
              desc =
                  "Now you can backup your secrets passphrase-encrypted json file of UCW Tss Node";
              items.add(Padding(
                  padding: const EdgeInsets.all(12),
                  child: TDLoading(
                    size: TDLoadingSize.small,
                    icon: TDLoadingIcon.point,
                    iconColor: TDTheme.of(context).brandNormalColor,
                    axis: Axis.horizontal,
                  )));
            case BackupStatus.secretsExported:
            case BackupStatus.completed:
              desc =
                  "Now export secrets passphrase-encrypted json file successfully. And save it to your local path: ${BackupBloc.shared().backupFilePath.value}";
              break;
          }
          return InfoSection(
              title: '1. Backup',
              desc: desc,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items));
        });
  }

  Future<void> _handleBackup() async {
    await BackupBloc.shared().backup();
  }
}
