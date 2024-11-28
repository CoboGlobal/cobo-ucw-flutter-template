import 'dart:io';
import 'package:cobo_flutter_template/blocs/main_group.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/ucw_sdk_init.dart';

final _logger = Logger((BackupBloc).toString());

enum BackupStatus {
  notStarted,
  readyToExport,
  secretsExporting,
  secretsExported,
  completed
}

class BackupBloc extends BaseBloc {
  final _status = BehaviorSubject<BackupStatus>.seeded(BackupStatus.notStarted);
  final _backupFilePath = BehaviorSubject<String>.seeded("");

  ValueStream<BackupStatus> get status => _status.stream;
  ValueStream<String> get backupFilePath => _backupFilePath.stream;

  static final BackupBloc _instance = BackupBloc._internal();
  factory BackupBloc.shared() => _instance;

  BackupBloc._internal() {
    _setupBloc();
  }

  void _setupBloc() async {
    MainGroupBloc.shared()
        .mainGroupStatus
        .where((ev) => ev == MainGroupStatus.completed)
        .listen((userInfo) {
      _status.add(BackupStatus.readyToExport);
    }).cancelBy(disposeBag);
  }

  Future<void> backup() async {
    _logger.info('Start to backup key group ...');
    _status.add(BackupStatus.secretsExporting);
    String? encryptedJSONData = await exportSecrets();
    _logger.info("======= encryptedJSONData: =======");
    _logger.info(encryptedJSONData);
    _logger.info("==================================");
    _status.add(BackupStatus.secretsExported);
    _logger.info("Now you can backup encrypted json data.");
    final mockBackupFilePath = await getBackupFilePath();
    final backupFile = File(mockBackupFilePath);
    if (!backupFile.parent.existsSync()) {
      backupFile.parent.createSync(recursive: true);
    }
    backupFile.writeAsStringSync(encryptedJSONData ?? '--');
    _backupFilePath.add(mockBackupFilePath);
    _logger.info(
        "Backup encrypted secrets data to local file successfully. path: $mockBackupFilePath");
    _status.add(BackupStatus.completed);
  }

  // Exports your Secrets file as a passphrase-encrypted JSON data of your TSS Node
  Future<String?> exportSecrets() async {
    String? encryptedJSONData;
    try {
      _logger.info("Start to export secrets...");
      String exportPassphrase = getExportPassphrase();
      encryptedJSONData = await UcwSdkInitBloc.shared()
          .ucwSdk
          .valueOrNull
          ?.exportSecrets(exportPassphrase);
      _logger.info("Export secrets successfully.");
    } catch (error) {
      _logger.severe("Key shares backup error, error:$error", error);
    }
    return encryptedJSONData;
  }

  // Provide a demo passphrase for encryption
  static String getExportPassphrase({bool reGenerate = false}) {
    return "MockExportPassword@12345678";
  }

  static Future<String> getBackupFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    String nodeID = UcwSdkInitBloc.shared().nodeId.valueOrNull ?? 'default';
    return "${dir.path}/ucw/${nodeID.substring(nodeID.length - 10)}.encrypted.json";
  }
}
