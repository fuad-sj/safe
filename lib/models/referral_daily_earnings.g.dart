// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_daily_earnings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralDailyEarnings _$ReferralDailyEarningsFromJson(
        Map<String, dynamic> json) =>
    ReferralDailyEarnings()
      ..user_id = json['user_id'] as String?
      ..user_name = json['user_name'] as String?
      ..user_phone = json['user_phone'] as String?
      ..earning_amount = FirebaseDocument.DoubleFromJson(json['earning_amount'])
      ..reference_counter = json['reference_counter'] as int?
      ..last_update = FirebaseDocument.DateTimeFromJson(json['last_update'])
      ..time_window = json['time_window'] as int?;

Map<String, dynamic> _$ReferralDailyEarningsToJson(
        ReferralDailyEarnings instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'user_name': instance.user_name,
      'user_phone': instance.user_phone,
      'earning_amount': instance.earning_amount,
      'reference_counter': instance.reference_counter,
      'last_update': FirebaseDocument.DateTimeToJson(instance.last_update),
      'time_window': instance.time_window,
    };
