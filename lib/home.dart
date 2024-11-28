import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'blocs/base.dart';
import 'steps/index.dart';

final _logger = Logger((HomePage).toString());

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends DisposableState<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: TDTheme.of(context).brandNormalColor,
            titleTextStyle: TextStyle(
                color: TDTheme.of(context).whiteColor1,
                fontSize: TDTheme.of(context).fontTitleLarge?.size),
            title: const Text('Cobo UCW Demo')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildGuideInfoSection(context),
              const SetupStep(),
              const WalletStep(),
              const TransactionStep(),
              const BackupRestoreStep(),
            ],
          ),
        ));
  }

  Padding _buildGuideInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: TDText.rich(TextSpan(children: [
          TDTextSpan(
              text:
                  "This demo gets you started with using MPC Wallets (User-Controlled Wallets). ",
              font: TDTheme.of(context).fontBodySmall,
              textColor: TDTheme.of(context).brandNormalColor),
          WidgetSpan(
              child: TDLink(
                  label: 'Click here',
                  linkClick: (uri) async {
                    await _launchCoboDocInBrowser();
                  },
                  color: TDTheme.of(context).brandNormalColor,
                  size: TDLinkSize.small,
                  type: TDLinkType.withUnderline)),
          TDTextSpan(
              text: " to view more in Cobo Developers Doc",
              font: TDTheme.of(context).fontBodySmall,
              textColor: TDTheme.of(context).brandNormalColor),
      ])),
    );
  }

  Future<void> _launchCoboDocInBrowser() async {
    String url =
        'https://www.cobo.com/developers/v2/guides/mpc-wallets/get-started-ucw';
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        _logger.severe("Could not launch $url");
      }
    } catch (e) {
      _logger.severe("Launch Cobo Doc In Browser error. url: $url, error: $e");
    }
  }
}
