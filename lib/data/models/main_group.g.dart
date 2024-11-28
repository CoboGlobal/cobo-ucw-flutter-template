// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainGroup _$MainGroupFromJson(Map<String, dynamic> json) => MainGroup(
      groupId: json['group_id'] as String,
      groupType: (json['group_type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MainGroupToJson(MainGroup instance) => <String, dynamic>{
      'group_id': instance.groupId,
      'group_type': instance.groupType,
    };
