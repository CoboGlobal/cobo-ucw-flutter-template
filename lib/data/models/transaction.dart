import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Fee {
  final String? feePerByte;
  final String? gasPrice;
  final String? gasLimit;
  final int? level;
  final String? maxFee;
  final String? maxPriorityFee;
  final String? tokenId;
  final String? feeAmount;

  Fee({
    this.feePerByte = "",
    this.gasPrice = "",
    this.gasLimit,
    this.level = 0,
    this.maxFee = "",
    this.maxPriorityFee = "",
    this.tokenId,
    this.feeAmount = "",
  });

  factory Fee.fromJson(Map<String, dynamic> json) => _$FeeFromJson(json);

  Map<String, dynamic> toJson() => _$FeeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionParams {
  final String from;
  final String to;
  final String amount;
  final String? tokenId;
  final String? chain;
  final int? type;
  final Fee? fee;
  final String? walletId;

  TransactionParams({
    required this.from,
    required this.to,
    required this.amount,
    this.tokenId,
    this.chain,
    this.type,
    this.fee,
    this.walletId,
  });

  factory TransactionParams.fromJson(Map<String, dynamic> json) =>
      _$TransactionParamsFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionParamsToJson(this);
}

class EstimateFee {
  final Fee slow;
  final Fee recommend;
  final Fee fast;

  EstimateFee({
    required this.slow,
    required this.recommend,
    required this.fast,
  });

  factory EstimateFee.fromJson(Map<String, dynamic> json) {
    return EstimateFee(
      slow: Fee.fromJson(json['slow']),
      recommend: Fee.fromJson(json['recommend']),
      fast: Fee.fromJson(json['fast']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slow': slow.toJson(),
      'recommend': recommend.toJson(),
      'fast': fast.toJson(),
    };
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionInfo {
  final String? transactionId;
  final int? type;
  final int? status;
  final int? subStatus;

  TransactionInfo({
    this.transactionId,
    this.type,
    this.status,
    this.subStatus,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) =>
      _$TransactionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionInfoToJson(this);
}
