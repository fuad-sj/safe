// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer()
  ..client_triggered_event = json['client_triggered_event'] as bool?
  ..phone_number = json['phone_number'] as String?
  ..user_name = json['user_name'] as String?
  ..last_user_name = json['last_user_name'] as String?
  ..referral_code = json['referral_code'] as String?
  ..gender = json['gender'] as int?
  ..email = json['email'] as String?
  ..version_number = json['version_number'] as String?
  ..num_children_under_node = json['num_children_under_node'] as int?
  ..datetime_version_date =
      FirebaseDocument.DateTimeFromJson(json['datetime_version_date'])
  ..last_checked_version_number = json['last_checked_version_number'] as String?
  ..last_checked_version_datetime =
      FirebaseDocument.DateTimeFromJson(json['last_checked_version_datetime'])
  ..has_dev_access = json['has_dev_access'] as bool?
  ..is_available_active = json['is_available_active'] as bool?
  ..date_created = FirebaseDocument.DateTimeFromJson(json['date_created'])
  ..date_last_login = FirebaseDocument.DateTimeFromJson(json['date_last_login'])
  ..is_active = json['is_active'] as bool? ?? true
  ..is_logged_in = json['is_logged_in'] as bool? ?? false
  ..device_registration_tokens =
      (json['device_registration_tokens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
  ..link_img_profile = json['link_img_profile'] as String?
  ..referral_activation_complete =
      json['referral_activation_complete'] as bool?;

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'client_triggered_event': instance.client_triggered_event,
      'phone_number': instance.phone_number,
      'user_name': instance.user_name,
      'last_user_name': instance.last_user_name,
      'referral_code': instance.referral_code,
      'gender': instance.gender,
      'email': instance.email,
      'version_number': instance.version_number,
      'num_children_under_node': instance.num_children_under_node,
      'datetime_version_date':
          FirebaseDocument.DateTimeToJson(instance.datetime_version_date),
      'last_checked_version_number': instance.last_checked_version_number,
      'last_checked_version_datetime': FirebaseDocument.DateTimeToJson(
          instance.last_checked_version_datetime),
      'has_dev_access': instance.has_dev_access,
      'is_available_active': instance.is_available_active,
      'date_created': FirebaseDocument.DateTimeToJson(instance.date_created),
      'date_last_login':
          FirebaseDocument.DateTimeToJson(instance.date_last_login),
      'is_active': instance.is_active,
      'is_logged_in': instance.is_logged_in,
      'device_registration_tokens': instance.device_registration_tokens,
      'link_img_profile': instance.link_img_profile,
      'referral_activation_complete': instance.referral_activation_complete,
    };
