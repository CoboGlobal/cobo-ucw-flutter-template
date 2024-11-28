// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fee _$FeeFromJson(Map<String, dynamic> json) => Fee(
      feePerByte: json['fee_per_byte'] as String? ?? "",
      gasPrice: json['gas_price'] as String? ?? "",
      gasLimit: json['gas_limit'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 0,
      maxFee: json['max_fee'] as String? ?? "",
      maxPriorityFee: json['max_priority_fee'] as String? ?? "",
      tokenId: json['token_id'] as String?,
      feeAmount: json['fee_amount'] as String? ?? "",
    );

Map<String, dynamic> _$FeeToJson(Fee instance) => <String, dynamic>{
      'fee_per_byte': instance.feePerByte,
      'gas_price': instance.gasPrice,
      'gas_limit': instance.gasLimit,
      'level': instance.level,
      'max_fee': instance.maxFee,
      'max_priority_fee': instance.maxPriorityFee,
      'token_id': instance.tokenId,
      'fee_amount': instance.feeAmount,
    };

TransactionParams _$TransactionParamsFromJson(Map<String, dynamic> json) =>
    TransactionParams(
      from: json['from'] as String,
      to: json['to'] as String,
      amount: json['amount'] as String,
      tokenId: json['token_id'] as String?,
      chain: json['chain'] as String?,
      type: (json['type'] as num?)?.toInt(),
      fee: json['fee'] == null
          ? null
          : Fee.fromJson(json['fee'] as Map<String, dynamic>),
      walletId: json['wallet_id'] as String?,
    );

Map<String, dynamic> _$TransactionParamsToJson(TransactionParams instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'amount': instance.amount,
      'token_id': instance.tokenId,
      'chain': instance.chain,
      'type': instance.type,
      'fee': instance.fee,
      'wallet_id': instance.walletId,
    };

TransactionInfo _$TransactionInfoFromJson(Map<String, dynamic> json) =>
    TransactionInfo(
      transactionId: json['transaction_id'] as String?,
      type: (json['type'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      subStatus: (json['sub_status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TransactionInfoToJson(TransactionInfo instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'type': instance.type,
      'status': instance.status,
      'sub_status': instance.subStatus,
    };
