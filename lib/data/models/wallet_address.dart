import 'package:cobo_flutter_template/data/models/token_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wallet_address.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class WalletAddress {
  final String walletId;
  final String address;
  final String chainId;
  final String? path;
  final String? pubkey;
  final String? encoding;

  WalletAddress({
    required this.walletId,
    required this.address,
    required this.chainId,
    this.path,
    this.pubkey,
    this.encoding,
  });

  factory WalletAddress.fromJson(Map<String, dynamic> json) =>
      _$WalletAddressFromJson(json);

  Map<String, dynamic> toJson() => _$WalletAddressToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TokenAddressInfo {
  final TokenInfo token;
  final List<WalletAddress> addresses;

  TokenAddressInfo({
    required this.token,
    required this.addresses,
  });

  factory TokenAddressInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenAddressInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TokenAddressInfoToJson(this);
}
