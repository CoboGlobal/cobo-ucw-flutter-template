import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/data/models/user_info.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/vault_info.dart';

class CreateVaultItem extends StatefulWidget {
  const CreateVaultItem({super.key});

  @override
  State<CreateVaultItem> createState() => _CreateVaultItemState();
}

class _CreateVaultItemState extends DisposableState<CreateVaultItem> {
  final _vaultInfo = BehaviorSubject<Vault?>();

  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {
    VaultInfoBloc.shared()
        .vaultInfo
        .distinct()
        .listen(_vaultInfo.add)
        .cancelBy(disposeBag);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: VaultInfoBloc.shared().vaultStatus,
        initialData: VaultStatus.notStarted,
        builder: (context, snapshot) {
          VaultStatus status = snapshot.data ?? VaultStatus.notStarted;
          Vault? vaultInfo = _vaultInfo.valueOrNull;
          final items = <Widget>[];
          String desc = '';
          switch (status) {
            case VaultStatus.notStarted:
              desc = "Not started";
              break;
            case VaultStatus.inProgress:
              items.add(Padding(
                  padding: const EdgeInsets.all(24),
                  child: TDLoading(
                    size: TDLoadingSize.small,
                    icon: TDLoadingIcon.point,
                    iconColor: TDTheme.of(context).brandNormalColor,
                  )));
              break;
            case VaultStatus.completed:
              items.addAll([
                ContextItem(
                  title: "Vault ID",
                  info: vaultInfo?.vaultId,
                ),
                const SizedBox(height: 8),
                ContextItem(
                  title: "Vault Name",
                  info: vaultInfo?.name,
                )
              ]);
              break;
          }
          return InfoSection(
              title: '3. Create a vault',
              desc: desc,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items));
        });
  }
}
