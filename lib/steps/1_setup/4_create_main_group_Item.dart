import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:ucw_sdk/data.dart' show TSSRequest;
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/main_group.dart';


class CreateMainGroupItem extends StatefulWidget {
  const CreateMainGroupItem({super.key});

  @override
  State<CreateMainGroupItem> createState() => _CreateMainGroupItemState();
}

class _CreateMainGroupItemState extends DisposableState<CreateMainGroupItem> {
  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: MainGroupBloc.shared().mainGroupStatus,
        initialData: MainGroupStatus.notStarted,
        builder: (context, snapshot) {
          MainGroupStatus status = snapshot.data ?? MainGroupStatus.notStarted;
          final items = <Widget>[];
          String desc = '';
          switch (status) {
            case MainGroupStatus.notStarted:
              desc = "Not started";
              break;
            case MainGroupStatus.readyToCreateMainGroup:
              desc = '1) Now you can create the main group key.';
              items.add(TDButton(
                  text: 'start to create',
                  theme: TDButtonTheme.primary,
                  size: TDButtonSize.small,
                  onTap: _handleStartKeygenEvent));
              break;
            case MainGroupStatus.createMainGroupRequesting:
              desc = '2) Start to request main group generation';
              items.add(Padding(
                    padding: const EdgeInsets.all(12),
                    child: TDLoading(
                      size: TDLoadingSize.small,
                      icon: TDLoadingIcon.point,
                      iconColor: TDTheme.of(context).brandNormalColor,
                      axis: Axis.horizontal,
                    )),
              );
              break;
            case MainGroupStatus.createMainGroupRequested:
              desc =
                  '3) Request main group generation successfully, now polling to check the status of the main group generation until it reaches "MpcProcessing" status...';
              items.addAll([
                ContextItem(
                  title: "Request ID",
                  info: MainGroupBloc.shared().tssRequestId.valueOrNull,
                ),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: TDLoading(
                      size: TDLoadingSize.small,
                      icon: TDLoadingIcon.point,
                      iconColor: TDTheme.of(context).brandNormalColor,
                      axis: Axis.horizontal,
                    ))
              ]);
              break; 
            case MainGroupStatus.pendingSdkTssRequestsQuerying:
            case MainGroupStatus.mpcProcessing:
              items.add(
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: TDLoading(
                      size: TDLoadingSize.small,
                      icon: TDLoadingIcon.point,
                      iconColor: TDTheme.of(context).brandNormalColor,
                      axis: Axis.horizontal,
                    )),
              );
              break;
            case MainGroupStatus.pendingSdkTssRequestsExisted:
              desc =
                  '4) Now you can approve the existed pending requests. Please click the button to approve.';
              final pendingTssRequests =
                  (MainGroupBloc.shared().pendingTssRequests.valueOrNull ?? []);
              items.addAll(_buildItemsForPendingSdkTssRequestsExisted(
                  pendingTssRequests));
              break;
            case MainGroupStatus.keyGenSdkApproving:
              desc =
                  "5) Now approving to participate key generation with sdk call";
              items.addAll([
                ContextItem(
                  title: "Request ID",
                  info: MainGroupBloc.shared().tssRequestId.valueOrNull,
                ),
                const SizedBox(height: 12),
                TDButton(
                    text: 'approve to participate',
                    theme: TDButtonTheme.primary,
                    size: TDButtonSize.small,
                    iconWidget: TDLoading(
                      size: TDLoadingSize.small,
                      icon: TDLoadingIcon.circle,
                      iconColor: TDTheme.of(context).whiteColor1,
                    ))
              ]);
              break;
            case MainGroupStatus.keyGenSdkApproved:
              desc =
                  "6) Approved to participate key generation successfully. Now polling to check the status of the main group generation until it reaches \"Complete\" status...";
              items.addAll([
                ContextItem(
                  title: "Request ID",
                  info: MainGroupBloc.shared().tssRequestId.valueOrNull,
                ),
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: TDLoading(
                      size: TDLoadingSize.small,
                      icon: TDLoadingIcon.point,
                      iconColor: TDTheme.of(context).brandNormalColor,
                      axis: Axis.horizontal,
                    ))
              ]);
              break;
            case MainGroupStatus.completed:
              desc = '7) A new main group key has been created successfully.';
              items.addAll([
                ContextItem(
                  title: "Main group key ID",
                  info: MainGroupBloc.shared().mainGroupId.valueOrNull,
                ),
              ]);
              break;
            case MainGroupStatus.failed:
              items.addAll([
                TDText(
                  "Failed to create main group key.",
                  maxLines: 2,
                  font: TDTheme.of(context).fontBodyMedium,
                  textColor: TDTheme.of(context).errorNormalColor,
                )
              ]);
              break;
          }
          return InfoSection(
              title: '4. Create a Main Group',
              desc: desc,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items));
        });
  }

  Iterable<Widget> _buildItemsForPendingSdkTssRequestsExisted(
      List<TSSRequest> pendingTssRequests) {
    final items = <Widget>[];
    for (var e in pendingTssRequests) {
      int index = pendingTssRequests.indexOf(e);
      items.addAll([
        ContextItem(
          title: "${index + 1}. Request ID: ",
          info: e.tssRequestID,
        ),
        const SizedBox(height: 8),
        TDButton(
            text: 'approve to participate',
            theme: TDButtonTheme.primary,
            size: TDButtonSize.small,
            onTap: () {
              _handleApproveKeygen(index);
            }),
        const SizedBox(height: 12),
      ]);
    }
    return items;
  }

  Future<void> _handleStartKeygenEvent() async {
    await MainGroupBloc.shared().startMainGroupGeneration();
    await MainGroupBloc.shared().pollingCheckStatusUntilMpcProcessing();
    await MainGroupBloc.shared().getPendingSdkTssRequests();
  }

  Future<void> _handleApproveKeygen(int idx) async {
    await MainGroupBloc.shared().approveMainGroupGenerationRequest(idx);
    await MainGroupBloc.shared().pollingCheckStatusUntilComplete(idx);
  }

}
