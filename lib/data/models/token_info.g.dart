// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      tokenId: json['token_id'] as String,
      name: json['name'] as String,
      decimal: (json['decimal'] as num).toInt(),
      symbol: json['symbol'] as String,
      chain: json['chain'] as String,
      iconUrl: json['icon_url'] as String,
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'token_id': instance.tokenId,
      'name': instance.name,
      'decimal': instance.decimal,
      'symbol': instance.symbol,
      'chain': instance.chain,
      'icon_url': instance.iconUrl,
    };

TokenInfo _$TokenInfoFromJson(Map<String, dynamic> json) => TokenInfo(
      token: Token.fromJson(json['token'] as Map<String, dynamic>),
      balance: json['balance'] as String,
      absBalance: json['abs_balance'] as String,
      available: json['available'] as String,
      locked: json['locked'] as String,
    );

Map<String, dynamic> _$TokenInfoToJson(TokenInfo instance) => <String, dynamic>{
      'token': instance.token,
      'balance': instance.balance,
      'abs_balance': instance.absBalance,
      'available': instance.available,
      'locked': instance.locked,
    };
