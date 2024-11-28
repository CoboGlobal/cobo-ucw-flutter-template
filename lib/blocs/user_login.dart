import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/shared_prefs.dart';
import 'package:cobo_flutter_template/data/api.dart';
import 'package:cobo_flutter_template/data/models/index.dart';

final _logger = Logger((UserLoginBloc).toString());

enum UserLoginStatus {
  notLoggedIn,
  loggingIn,
  loggedIn,
  gettingUserInfo,
  completed
}

class UserLoginBloc extends BaseBloc {
  static final UserLoginBloc _instance = UserLoginBloc._internal();
  factory UserLoginBloc.shared() => _instance;
  final ApiService api = ApiService();

  UserLoginBloc._internal() {
    _setupBloc();
  }

  final _userLoginStatus =
      BehaviorSubject<UserLoginStatus>.seeded(UserLoginStatus.notLoggedIn);
  final _token = BehaviorSubject<String>.seeded("");
  final _userInfo = BehaviorSubject<UserInfo?>();

  ValueStream<UserLoginStatus> get userLoginStatus => _userLoginStatus.stream;
  ValueStream<String> get token => _token.stream;
  ValueStream<UserInfo?> get userInfo => _userInfo.stream;

  void _setupBloc() async {
    _token.distinct().where((ev) => ev.isNotEmpty).listen((token) {
      getUserInfo();
    }).cancelBy(disposeBag);
  }

  Future<void> init() async {
    _logger.info('Init login bloc.');
    await loadToken();
  }

  Future<void> loadToken() async {
    String token = (await SharedPrefs.get(SharedPrefs.keyToken)) ?? "";
    _token.add(token);
    _logger.info('Load token. token: $token');
    if (token.isNotEmpty) {
      _userLoginStatus.add(UserLoginStatus.loggedIn);
    } else {
      _logger
          .info('Token is empty. please log in only email for demonstration');
    }
  }

  Future<void> login(String email, BuildContext context) async {
    try {
      if (email.isEmpty || !_isEmailValid(email)) {
        TDToast.showText('Invalid email address', context: context);
        return;
      }
      if (UserLoginStatus.loggingIn == _userLoginStatus.value) {
        return;
      }
      _logger.info('Start to login ...');
      _userLoginStatus.add(UserLoginStatus.loggingIn);
      LoginToken? loginToken = await api.login(email) ?? LoginToken(token: "");
      _logger.info('Login successful.');
      _token.add(loginToken.token);
      _userLoginStatus.add(UserLoginStatus.loggedIn);
      SharedPrefs.save(SharedPrefs.keyToken, loginToken.token);
      _logger.info('Save token successful. token: ${loginToken.token}');
    } catch (e) {
      _userLoginStatus.add(UserLoginStatus.notLoggedIn);
      _logger.severe('Login error occurred: $e');
    }
  }

  Future<void> getUserInfo() async {
    try {
      if (UserLoginStatus.gettingUserInfo == _userLoginStatus.value) {
        return;
      }
      _logger.info('Start to get user info ...');
      _userLoginStatus.add(UserLoginStatus.gettingUserInfo);
      final token = _token.value;
      UserInfo userInfo = await api.getUserInfo(token);
      _logger.info('Get user info successful.');
      _userInfo.add(userInfo);
      _userLoginStatus.add(UserLoginStatus.completed);
    } catch (e) {
      _token.add(""); // delete local token
      _userLoginStatus.add(UserLoginStatus.notLoggedIn);
      _logger.severe('Get user info error occurred: $e');
      _logger.info('Please login again in demo.');
    }
  }

  bool _isEmailValid(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[^@]+@[^@]+\.[^@]+$',
    );
    return emailRegExp.hasMatch(email);
  }
}
