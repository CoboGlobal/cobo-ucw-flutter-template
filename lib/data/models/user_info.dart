import 'package:json_annotation/json_annotation.dart';

part 'user_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserInfo {
  final User? user;
  final Vault? vault;
  final Wallet? wallet;
  final List<UserNode>? userNodes;

  UserInfo({
    this.user,
    this.vault,
    this.wallet,
    this.userNodes,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String userId;
  final String? email;

  User({
    required this.userId,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Vault {
  final String vaultId;
  final String? name;
  final String? mainGroupId;
  final String? projectId;
  final String? coboNodeId;
  final int? status;

  Vault({
    required this.vaultId,
    this.name,
    this.mainGroupId,
    this.projectId,
    this.coboNodeId,
    this.status,
  });

  factory Vault.fromJson(Map<String, dynamic> json) => _$VaultFromJson(json);
  Map<String, dynamic> toJson() => _$VaultToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Wallet {
  final String walletId;
  final String? walletType;
  final String? walletSubtype;
  final String? name;
  final String? orgId;

  Wallet({
    required this.walletId,
    this.walletType,
    this.walletSubtype,
    this.name,
    this.orgId,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserNode {
  final String nodeId;
  final String? userId;
  final int? role;

  UserNode({
    required this.nodeId,
    this.userId,
    this.role,
  });

  factory UserNode.fromJson(Map<String, dynamic> json) =>
      _$UserNodeFromJson(json);
  Map<String, dynamic> toJson() => _$UserNodeToJson(this);
}
