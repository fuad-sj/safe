// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_transaction_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralTransactionLog _$ReferralTransactionLogFromJson(
        Map<String, dynamic> json) =>
    ReferralTransactionLog()
      ..array_index = json['array_index'] as int?
      ..user_id = json['user_id'] as String?
      ..user_phone = json['user_phone'] as String?
      ..user_name = json['user_name'] as String?
      ..trans_amount = FirebaseDocument.DoubleFromJson(json['trans_amount'])
      ..trans_type = json['trans_type'] as int?
      ..trans_timestamp =
          FirebaseDocument.DateTimeFromJson(json['trans_timestamp'])
      ..date_time_window = json['date_time_window'] as int?;

Map<String, dynamic> _$ReferralTransactionLogToJson(
        ReferralTransactionLog instance) =>
    <String, dynamic>{
      'array_index': instance.array_index,
      'user_id': instance.user_id,
      'user_phone': instance.user_phone,
      'user_name': instance.user_name,
      'trans_amount': instance.trans_amount,
      'trans_type': instance.trans_type,
      'trans_timestamp':
          FirebaseDocument.DateTimeToJson(instance.trans_timestamp),
      'date_time_window': instance.date_time_window,
    };
