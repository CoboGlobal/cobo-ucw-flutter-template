import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/data/models/user_info.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/wallet_info.dart';

class CreateWalletItem extends StatefulWidget {
  const CreateWalletItem({super.key});

  @override
  State<CreateWalletItem> createState() => _CreateWalletItemState();
}

class _CreateWalletItemState extends DisposableState<CreateWalletItem> {
  final _walletInfo = BehaviorSubject<Wallet?>();

  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {
    WalletInfoBloc.shared()
        .walletInfo
        .distinct()
        .listen(_walletInfo.add)
        .cancelBy(disposeBag);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: WalletInfoBloc.shared().walletStatus,
        initialData: WalletStatus.notStarted,
        builder: (context, snapshot) {
          WalletStatus status = snapshot.data ?? WalletStatus.notStarted;
          Wallet? walletInfo = _walletInfo.valueOrNull;
          final items = <Widget>[];
          String desc = '';
          switch (status) {
            case WalletStatus.notStarted:
              desc = "Not started";
              break;
            case WalletStatus.inProgress:
              items.add(Padding(
                  padding: const EdgeInsets.all(24),
                  child: TDLoading(
                    size: TDLoadingSize.small,
                    icon: TDLoadingIcon.point,
                    iconColor: TDTheme.of(context).brandNormalColor,
                  )));
              break;
            case WalletStatus.completed:
              items.addAll([
                ContextItem(
                  title: "Wallet ID",
                  info: walletInfo?.walletId,
                )
              ]);
              if (walletInfo?.name != null) {
                items.addAll([
                  const SizedBox(height: 8),
                  ContextItem(
                    title: "Wallet Name",
                    info: walletInfo?.name,
                  )
                ]);
              }
              break;
          }
          return InfoSection(
              title: '1. Create a wallet',
              desc: desc,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items));
        });
  }
}
