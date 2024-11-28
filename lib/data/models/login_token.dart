class LoginToken {
  final String token;

  LoginToken({required this.token});

  factory LoginToken.fromJson(Map<String, dynamic> json) {
    return LoginToken(
      token: json['token'],
    );
  }
}
