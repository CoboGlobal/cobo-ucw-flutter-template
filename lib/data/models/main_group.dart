import 'package:json_annotation/json_annotation.dart';

part 'main_group.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MainGroup {
  final String groupId;
  final int? groupType;

  MainGroup({
    required this.groupId,
    this.groupType,
  });

  factory MainGroup.fromJson(Map<String, dynamic> json) =>
      _$MainGroupFromJson(json);

  Map<String, dynamic> toJson() => _$MainGroupToJson(this);
}

enum KeyGroupType {
  mainGroup(0),
  signingGroup(1),
  recoveryGroup(2);

  final int value;
  const KeyGroupType(this.value);
}

class KeyGroupStatus {
  static const int unspecified = 0;
  static const int created = 1;
  static const int mainGroupCreated = 20;
  static const int mainGenerated = 30;
}
