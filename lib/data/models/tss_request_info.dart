import 'package:json_annotation/json_annotation.dart';

part 'tss_request_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TssRequestInfo {
  final String requestId;
  final int? type;
  final int? status;
  final String? sourceGroupId;
  final String? targetGroupId;
  final String? createTimestamp;

  TssRequestInfo({
    required this.requestId,
    this.type,
    this.status,
    this.sourceGroupId,
    this.targetGroupId,
    this.createTimestamp,
  });

  factory TssRequestInfo.fromJson(Map<String, dynamic> json) =>
      _$TssRequestInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TssRequestInfoToJson(this);
}

class TssRequestInfoStatus {
  static const int statusUnspecified = 0;
  static const int statusPendingKeyholderConfirmation = 10;
  static const int statusKeyholderConfirmationFailed = 20;
  static const int statusKeyGenerating = 30;
  static const int statusMpcProcessing = 35;
  static const int statusKeyGeneratingFailed = 40;
  static const int statusSuccess = 50;
}
