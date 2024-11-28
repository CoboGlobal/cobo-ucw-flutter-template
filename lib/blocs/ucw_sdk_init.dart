import 'dart:io';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ucw_sdk/data.dart' show ConnCode, Env, SDKConfig, SDKInfo;
import 'package:ucw_sdk/ucw_sdk.dart'
    show UCW, getSDKInfo, initializeSecrets, setLogger;
import 'package:path_provider/path_provider.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';
import 'package:cobo_flutter_template/data/api.dart';

final _logger = Logger((UcwSdkInitBloc).toString());

enum NodeStatus {
  notStarted,
  ucwSdkSecretsCreating,
  ucwSdkNodeInitializing,
  completed
}

class UcwSdkInitBloc extends BaseBloc {
  static final UcwSdkInitBloc _instance = UcwSdkInitBloc._internal();
  factory UcwSdkInitBloc.shared() => _instance;
  final ApiService api = ApiService();

  UcwSdkInitBloc._internal() {
    _setupBloc();
  }

  final _nodeStatus = BehaviorSubject<NodeStatus>.seeded(NodeStatus.notStarted);
  final _nodeId = BehaviorSubject<String>();
  final _ucwSdk = BehaviorSubject<UCW>();

  ValueStream<NodeStatus> get nodeStatus => _nodeStatus.stream;
  ValueStream<String> get nodeId => _nodeId.stream;
  ValueStream<UCW> get ucwSdk => _ucwSdk.stream;

  void _setupBloc() async {
    UserLoginBloc.shared()
        .userLoginStatus
        .where((ev) => ev == UserLoginStatus.completed)
        .listen((ev) {
      init();
    }).cancelBy(disposeBag);
  }

  @override
  void dispose() {
    super.dispose();
    _nodeStatus.close();
    _nodeId.close();
    _ucwSdk.close();
  }

  Future<void> init() async {
    SDKInfo sdkInfo = await getSDKInfo();
    _logger.info('Get UCW SDK info. version: ${sdkInfo.version}');
    setLogger(logCallback);
    _logger.info('Set UCW SDK Log Listener successfully.');
    final secretsPath = await getUcwSecretsFilePath();
    final secretsExists = await File(secretsPath).exists();
    final passPhrase = getUcwPassphrase();
    if (!secretsExists) {
      await initializeUcwSecrets(secretsPath, passPhrase);
    }
    await createUcwClass(secretsPath, passPhrase);
  }

  Future<void> initializeUcwSecrets(
      String secretsPath, String passPhrase) async {
    try {
      _logger.info('Start to initialize UCW SDK secrets file...');
      _nodeStatus.add(NodeStatus.ucwSdkSecretsCreating);
      await initializeSecrets(secretsPath, passPhrase);
      _logger.info('Initialize UCW SDK secrets file successfully.');
    } catch (e) {
      _logger.severe('Initialize UCW SDK secrets file error occurred: $e');
    }
  }

  Future<void> createUcwClass(String secretsPath, String passPhrase) async {
    _logger.info('Start to create UCW class...');
    try {
      final sdkConf = SDKConfig(
        env: Env.sandbox,
        timeout: 30,
        debug: true,
      );
      final ucwSdk = await UCW.create(
          secretsFile: secretsPath,
          config: sdkConf,
          passphrase: passPhrase,
          connCallback: connCallback);
      _ucwSdk.add(ucwSdk);
      _logger.info('Create UCW class successfully.');
      _logger.info('Start to get node ID...');
      String nodeID = await ucwSdk.getTSSNodeID();
      _nodeStatus.add(NodeStatus.completed);
      _nodeId.add(nodeID);
      _logger.info('Get node id successfully. nodeID: $nodeID');
    } catch (e) {
      _logger.severe('Create UCW class error occurred: $e');
    }
  }

  // Mock UCW SDK secrets file path
  static Future<String> getUcwSecretsFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/ucw_tss_sdk_demo/secrets.db";
  }

  // Mock UCW SDK passphrase
  static String getUcwPassphrase({bool reGenerate = false}) {
    return "MockDbPassword@12345678";
  }

  // UCW SDK connection state listen callback
  void connCallback(ConnCode connCode, String connMessage) {
    // _logger
    //     .info('UCW SDK Connection state: $connCode, connMessage: $connMessage');
  }

  // UCW SDK log listen callback
  void logCallback(String level, String message) {
    // _logger.info('UCW SDK Log Level: $level, Message: $message');
  }
}
