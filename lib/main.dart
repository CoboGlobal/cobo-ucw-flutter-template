import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/blocs/logging.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';
import 'package:cobo_flutter_template/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TDThemeData _themeData;
  Locale? locale = const Locale('en', 'US');

  @override
  void initState() {
    super.initState();
    _themeData = TDThemeData.defaultData();
    appInit(); // Init all the blocs
  }

  void appInit() async {
    LoggingBloc().init();
    await UserLoginBloc.shared().init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(extensions: [_themeData], colorScheme: ColorScheme.light(primary: _themeData.brandNormalColor), scaffoldBackgroundColor:  TDTheme.of(context).grayColor1 ),
      home: const HomePage(),
      locale: locale,
    );
  }
  
}