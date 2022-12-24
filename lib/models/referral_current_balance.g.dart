// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_current_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralCurrentBalance _$ReferralCurrentBalanceFromJson(
        Map<String, dynamic> json) =>
    ReferralCurrentBalance()
      ..user_id = json['user_id'] as String?
      ..user_name = json['user_name'] as String?
      ..user_phone = json['user_phone'] as String?
      ..current_balance =
          FirebaseDocument.DoubleFromJson(json['current_balance'])
      ..last_update_timestamp =
          FirebaseDocument.DateTimeFromJson(json['last_update_timestamp'])
      ..last_update_trans_type = json['last_update_trans_type'] as int?;

Map<String, dynamic> _$ReferralCurrentBalanceToJson(
        ReferralCurrentBalance instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'user_name': instance.user_name,
      'user_phone': instance.user_phone,
      'current_balance': instance.current_balance,
      'last_update_timestamp':
          FirebaseDocument.DateTimeToJson(instance.last_update_timestamp),
      'last_update_trans_type': instance.last_update_trans_type,
    };
