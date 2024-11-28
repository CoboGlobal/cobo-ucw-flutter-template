// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_bind_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBindNode _$UserBindNodeFromJson(Map<String, dynamic> json) => UserBindNode(
      userId: json['user_id'] as String,
      nodeId: json['node_id'] as String,
      role: (json['role'] as num).toInt(),
    );

Map<String, dynamic> _$UserBindNodeToJson(UserBindNode instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'node_id': instance.nodeId,
      'role': instance.role,
    };
