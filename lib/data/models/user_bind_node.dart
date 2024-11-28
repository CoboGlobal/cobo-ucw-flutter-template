import 'package:json_annotation/json_annotation.dart';

part 'user_bind_node.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserBindNode {
  final String userId;
  final String nodeId;
  final int role;

  UserBindNode({
    required this.userId,
    required this.nodeId,
    required this.role,
  });

  factory UserBindNode.fromJson(Map<String, dynamic> json) =>
      _$UserBindNodeFromJson(json);

  Map<String, dynamic> toJson() => _$UserBindNodeToJson(this);
}
