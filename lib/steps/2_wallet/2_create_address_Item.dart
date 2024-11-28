import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/data/models/index.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/wallet_address.dart';

class CreateAddressItem extends StatefulWidget {
  const CreateAddressItem({super.key});

  @override
  State<CreateAddressItem> createState() => _CreateWalletItemState();
}

class _CreateWalletItemState extends DisposableState<CreateAddressItem> {
  final _walletAddress = BehaviorSubject<WalletAddress?>();

  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {
    WalletAddressBloc.shared()
        .walletAddress
        .distinct()
        .listen(_walletAddress.add)
        .cancelBy(disposeBag);

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: WalletAddressBloc.shared().walletAddressStatus,
        initialData: WalletAddressStatus.notStarted,
        builder: (context, snapshot) {
          WalletAddressStatus status =
              snapshot.data ?? WalletAddressStatus.notStarted;
          WalletAddress? walletAddress =
              WalletAddressBloc.shared().walletAddress.valueOrNull;
          TokenInfo? tokenInfo =
              WalletAddressBloc.shared().tokenInfo.valueOrNull;
          final items = <Widget>[];
          String desc = '';
          switch (status) {
            case WalletAddressStatus.notStarted:
              desc = "Not started";
              break;
            case WalletAddressStatus.tokenAddressCreating:
            case WalletAddressStatus.tokenAddressInfoQuerying:
              items.add(SizedBox(
                height: 110,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TDLoading(
                    size: TDLoadingSize.small,
                    icon: TDLoadingIcon.point,
                    iconColor: TDTheme.of(context).brandNormalColor,
                    )),
              ));
              break;
            case WalletAddressStatus.tokenAddressCreated:
            case WalletAddressStatus.tokenAddressInfoQueryed:
            case WalletAddressStatus.completed:
              items.addAll([
                ContextItem(
                  title: "address",
                  info: walletAddress?.address,
                ),
                const SizedBox(height: 8),
                ContextItem(
                  title: "Chain",
                  info: tokenInfo?.token.chain,
                ),
                const SizedBox(height: 8),
                ContextItem(
                  title: "Token Name",
                  info: tokenInfo?.token.symbol,
                ),
                const SizedBox(height: 8),
                ContextItem(
                  title: "Token Balance",
                  info: tokenInfo?.balance,
                )
              ]);
              break;
          }
          return InfoSection(
              title: '2. Create an address',
              desc: desc,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items));
        });
  }
}
