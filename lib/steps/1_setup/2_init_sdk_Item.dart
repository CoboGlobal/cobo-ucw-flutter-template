import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/ucw_sdk_init.dart';

class InitSDKItem extends StatefulWidget {
  const InitSDKItem({super.key});

  @override
  State<InitSDKItem> createState() => _InitSDKItemState();
}

class _InitSDKItemState extends DisposableState<InitSDKItem> {
  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UcwSdkInitBloc.shared().nodeStatus,
      initialData: NodeStatus.notStarted,
      builder: (context, snapshot) {
        NodeStatus status = snapshot.data ?? NodeStatus.notStarted;
        String? tssNodeID = UcwSdkInitBloc.shared().nodeId.valueOrNull;
        final items = <Widget>[];
        String desc =
            'This initialization sets up the TSS Node ID, a unique identifier for the node participating in key generation.';
        switch (status) {
          case NodeStatus.notStarted:
            desc = "Not started";
            break;
          case NodeStatus.ucwSdkSecretsCreating:
            desc = "The UCW SDK secrets file is currently being created";
            items.add(Padding(
                padding: const EdgeInsets.all(24),
                child: TDLoading(
                  size: TDLoadingSize.small,
                  icon: TDLoadingIcon.point,
                  iconColor: TDTheme.of(context).brandNormalColor,
                )));
            break;
          case NodeStatus.ucwSdkNodeInitializing:
            desc = "The UCW SDK Tss Node is currently being initialized";
            items.add(Padding(
                padding: const EdgeInsets.all(24),
                child: TDLoading(
                  size: TDLoadingSize.small,
                  icon: TDLoadingIcon.point,
                  iconColor: TDTheme.of(context).brandNormalColor,
                )));
            break;
          case NodeStatus.completed:
            desc = "The TSS Node initialization is completed.";
            items.addAll([
              ContextItem(
                title: "Node ID",
                info: tssNodeID,
              ),
            ]);
            break;
        }
        return InfoSection(
            title: '2. Initialize the UCW SDK',
            desc: desc,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: items));
      },
    );
  }
}
