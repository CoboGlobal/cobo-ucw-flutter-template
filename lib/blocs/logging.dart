import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LoggingBloc {
  static final LoggingBloc _instance = LoggingBloc._internal();
  factory LoggingBloc() => _instance;

  LoggingBloc._internal();

  void init() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(_onRecord);
  }

  void _onRecord(LogRecord record) {
    if (kDebugMode) {
      final log = "${record.time}|${record.level.name}|${record.loggerName}|"
          " ${record.message}";
      printLongText(log);
      if (record.stackTrace != null) {
        print(record.stackTrace);
      }
    }
  }
}

void printLongText(String text) {
  final pattern = RegExp('.{1,1000}'); 
  // ignore: avoid_print
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
