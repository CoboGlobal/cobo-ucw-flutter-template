import 'package:json_annotation/json_annotation.dart';

part 'token_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Token {
  final String tokenId;
  final String name;
  final int decimal;
  final String symbol;
  final String chain;
  final String iconUrl;

  Token({
    required this.tokenId,
    required this.name,
    required this.decimal,
    required this.symbol,
    required this.chain,
    required this.iconUrl,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TokenInfo {
  final Token token;
  final String balance;
  final String absBalance;
  final String available;
  final String locked;

  TokenInfo({
    required this.token,
    required this.balance,
    required this.absBalance,
    required this.available,
    required this.locked,
  });

  factory TokenInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenInfoToJson(this);
}
