import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:cobo_flutter_template/common/container.dart';
import 'package:cobo_flutter_template/data/models/user_info.dart';
import 'package:cobo_flutter_template/blocs/base.dart';
import 'package:cobo_flutter_template/blocs/user_login.dart';


class UserLoginItem extends StatefulWidget {
  const UserLoginItem({super.key});

  @override
  State<UserLoginItem> createState() => _UserLoginItemState();
}

class _UserLoginItemState extends DisposableState<UserLoginItem> {
  final _userLoginBlocShared = UserLoginBloc.shared();
  final _apiLoading = BehaviorSubject<bool>.seeded(false);
  final _token = BehaviorSubject<String>.seeded("");
  final _userInfo = BehaviorSubject<UserInfo?>();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupBloc();
  }

  void _setupBloc() async {
    _userLoginBlocShared.token.listen(_token.add).cancelBy(disposeBag);
    _userLoginBlocShared.userInfo
        .where((evt) => evt != null)
        .listen(_userInfo.add)
        .cancelBy(disposeBag);
    _userLoginBlocShared.loading.listen(_apiLoading.add).cancelBy(disposeBag);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserLoginBloc.shared().userLoginStatus,
      initialData: UserLoginStatus.notLoggedIn,
      builder: (context, snapshot) {
        UserLoginStatus status = snapshot.data ?? UserLoginStatus.notLoggedIn;
        Widget item;
        switch (status) {
          case UserLoginStatus.notLoggedIn:
            item = _buildLoginSection(loggingIn: false);
            break;
          case UserLoginStatus.loggingIn:
            item = _buildLoginSection(loggingIn: true);
            break;
          case UserLoginStatus.loggedIn:
          case UserLoginStatus.gettingUserInfo:
          case UserLoginStatus.completed:
            item = _buildUserInfoSection();
            break;
        }
        return item;
      },
    );
  }

  Widget _buildLoginSection({loggingIn = false}) {
    return InfoSection(
      title: '1. Authentication',
      desc:
          'Log in user\'s email with the Client Backend to access the Cobo UCW Demo',
      child: _buildLoginItem(loggingIn),
    );
  }

  Widget _buildUserInfoSection() {
    return StreamBuilder(
      stream: _userInfo,
      builder: (context, snapshot) {
        final user = snapshot.data?.user;
        final items = <Widget>[];
        String loginedDesc = 'The user details you currently logged in';
        if (user != null) {
          items.addAll([
            ContextItem(
              title: "User ID",
              info: user.userId,
            ),
            const SizedBox(height: 4),
            ContextItem(
              title: "Email",
              info: user.email,
            )
          ]);
        } else {
          items.add(Padding(
              padding: const EdgeInsets.all(24),
              child: TDLoading(
                size: TDLoadingSize.small,
                icon: TDLoadingIcon.point,
                iconColor: TDTheme.of(context).brandNormalColor,
              )));
          loginedDesc = "";
        }
        return InfoSection(
            title: '1. Authentication',
            desc: loginedDesc,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: items));
      },
    );
  }

  Widget _buildLoginItem(bool loggingIn) {
    Widget? rightBtnItem;
    if (loggingIn) {
      rightBtnItem = TDButton(
          text: 'Login',
          size: TDButtonSize.extraSmall,
          theme: TDButtonTheme.primary,
          iconWidget: TDLoading(
            size: TDLoadingSize.small,
            icon: TDLoadingIcon.circle,
            iconColor: TDTheme.of(context).whiteColor1,
          ));
    }
    return TDInput(
      type: TDInputType.cardStyle,
      size: TDInputSize.small,
      cardStyle: TDCardStyle.topText,
      controller: _controller,
      hintText: 'Please type email',
      backgroundColor: Colors.white,
      rightBtn: rightBtnItem ??
          TDButton(
            text: 'Login',
            size: TDButtonSize.extraSmall,
            theme: TDButtonTheme.primary,
            onTap: () {
              String email = _controller.text;
              _userLoginBlocShared.login(email, context);
            },
          ),
      needClear: false,
    );
  }
}
