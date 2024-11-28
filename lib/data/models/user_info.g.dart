// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      vault: json['vault'] == null
          ? null
          : Vault.fromJson(json['vault'] as Map<String, dynamic>),
      wallet: json['wallet'] == null
          ? null
          : Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
      userNodes: (json['user_nodes'] as List<dynamic>?)
          ?.map((e) => UserNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'user': instance.user,
      'vault': instance.vault,
      'wallet': instance.wallet,
      'user_nodes': instance.userNodes,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['user_id'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'email': instance.email,
    };

Vault _$VaultFromJson(Map<String, dynamic> json) => Vault(
      vaultId: json['vault_id'] as String,
      name: json['name'] as String?,
      mainGroupId: json['main_group_id'] as String?,
      projectId: json['project_id'] as String?,
      coboNodeId: json['cobo_node_id'] as String?,
      status: (json['status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VaultToJson(Vault instance) => <String, dynamic>{
      'vault_id': instance.vaultId,
      'name': instance.name,
      'main_group_id': instance.mainGroupId,
      'project_id': instance.projectId,
      'cobo_node_id': instance.coboNodeId,
      'status': instance.status,
    };

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
      walletId: json['wallet_id'] as String,
      walletType: json['wallet_type'] as String?,
      walletSubtype: json['wallet_subtype'] as String?,
      name: json['name'] as String?,
      orgId: json['org_id'] as String?,
    );

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
      'wallet_id': instance.walletId,
      'wallet_type': instance.walletType,
      'wallet_subtype': instance.walletSubtype,
      'name': instance.name,
      'org_id': instance.orgId,
    };

UserNode _$UserNodeFromJson(Map<String, dynamic> json) => UserNode(
      nodeId: json['node_id'] as String,
      userId: json['user_id'] as String?,
      role: (json['role'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserNodeToJson(UserNode instance) => <String, dynamic>{
      'node_id': instance.nodeId,
      'user_id': instance.userId,
      'role': instance.role,
    };
