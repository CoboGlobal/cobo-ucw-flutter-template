// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletAddress _$WalletAddressFromJson(Map<String, dynamic> json) =>
    WalletAddress(
      walletId: json['wallet_id'] as String,
      address: json['address'] as String,
      chainId: json['chain_id'] as String,
      path: json['path'] as String?,
      pubkey: json['pubkey'] as String?,
      encoding: json['encoding'] as String?,
    );

Map<String, dynamic> _$WalletAddressToJson(WalletAddress instance) =>
    <String, dynamic>{
      'wallet_id': instance.walletId,
      'address': instance.address,
      'chain_id': instance.chainId,
      'path': instance.path,
      'pubkey': instance.pubkey,
      'encoding': instance.encoding,
    };

TokenAddressInfo _$TokenAddressInfoFromJson(Map<String, dynamic> json) =>
    TokenAddressInfo(
      token: TokenInfo.fromJson(json['token'] as Map<String, dynamic>),
      addresses: (json['addresses'] as List<dynamic>)
          .map((e) => WalletAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenAddressInfoToJson(TokenAddressInfo instance) =>
    <String, dynamic>{
      'token': instance.token,
      'addresses': instance.addresses,
    };
