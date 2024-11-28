// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tss_request_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TssRequestInfo _$TssRequestInfoFromJson(Map<String, dynamic> json) =>
    TssRequestInfo(
      requestId: json['request_id'] as String,
      type: (json['type'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      sourceGroupId: json['source_group_id'] as String?,
      targetGroupId: json['target_group_id'] as String?,
      createTimestamp: json['create_timestamp'] as String?,
    );

Map<String, dynamic> _$TssRequestInfoToJson(TssRequestInfo instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'type': instance.type,
      'status': instance.status,
      'source_group_id': instance.sourceGroupId,
      'target_group_id': instance.targetGroupId,
      'create_timestamp': instance.createTimestamp,
    };
