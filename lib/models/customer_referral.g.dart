// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_referral.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralRequest _$ReferralRequestFromJson(Map<String, dynamic> json) =>
    ReferralRequest()
      ..referral_parent_code = json['referral_parent_code'] as String?
      ..referral_child_id = json['referral_child_id'] as String?
      ..referral_status_code = json['referral_status_code'] as int?
      ..date_referral =
          FirebaseDocument.DateTimeFromJson(json['date_referral']);

Map<String, dynamic> _$ReferralRequestToJson(ReferralRequest instance) =>
    <String, dynamic>{
      'referral_parent_code': instance.referral_parent_code,
      'referral_child_id': instance.referral_child_id,
      'referral_status_code': instance.referral_status_code,
      'date_referral': FirebaseDocument.DateTimeToJson(instance.date_referral),
    };
