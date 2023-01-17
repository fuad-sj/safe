// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver()
  ..client_triggered_event = json['client_triggered_event'] as bool?
  ..phone_number = json['phone_number'] as String?
  ..user_name = json['user_name'] as String?
  ..last_user_name = json['last_user_name'] as String?
  ..referral_code = json['referral_code'] as String?
  ..gender = json['gender'] as int?
  ..email = json['email'] as String?
  ..version_number = json['version_number'] as String?
  ..version_build_number = json['version_build_number'] as int?
  ..num_direct_children = json['num_direct_children'] as int?
  ..num_total_children = json['num_total_children'] as int?
  ..last_read_current_balance =
      FirebaseDocument.DoubleFromJson(json['last_read_current_balance'])
  ..last_read_total_children = json['last_read_total_children'] as int?
  ..datetime_version_date =
      FirebaseDocument.DateTimeFromJson(json['datetime_version_date'])
  ..last_checked_version_number = json['last_checked_version_number'] as String?
  ..last_checked_version_datetime =
      FirebaseDocument.DateTimeFromJson(json['last_checked_version_datetime'])
  ..last_checked_build_number = json['last_checked_build_number'] as int?
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
  ..referral_activation_complete = json['referral_activation_complete'] as bool?
  ..car_type = json['car_type'] as int?
  ..profile_status = json['profile_status'] as int?
  ..car_color = json['car_color'] as String?
  ..car_number = json['car_number'] as String?
  ..car_model = json['car_model'] as String?
  ..driver_rating = (json['driver_rating'] as num?)?.toDouble()
  ..num_rating = json['num_rating'] as int?
  ..link_img_common_profile = json['link_img_common_profile'] as String?
  ..img_status_common_profile = json['img_status_common_profile'] as int?
  ..link_img_common_libre = json['link_img_common_libre'] as String?
  ..img_status_common_libre = json['img_status_common_libre'] as int?
  ..link_img_common_driving_license =
      json['link_img_common_driving_license'] as String?
  ..img_status_common_driving_license =
      json['img_status_common_driving_license'] as int?
  ..link_img_common_insurance = json['link_img_common_insurance'] as String?
  ..img_status_common_insurance = json['img_status_common_insurance'] as int?
  ..is_representative = json['is_representative'] as bool?
  ..link_img_common_representative =
      json['link_img_common_representative'] as String?
  ..img_status_common_representative =
      json['img_status_common_representative'] as int?
  ..link_img_code_3_tin_number = json['link_img_code_3_tin_number'] as String?
  ..img_status_code_3_tin_number = json['img_status_code_3_tin_number'] as int?
  ..link_img_code_3_business_license =
      json['link_img_code_3_business_license'] as String?
  ..img_status_code_3_business_license =
      json['img_status_code_3_business_license'] as int?
  ..link_img_code_1_mahiber_wul = json['link_img_code_1_mahiber_wul'] as String?
  ..img_status_code_1_mahiber_wul =
      json['img_status_code_1_mahiber_wul'] as int?;

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'client_triggered_event': instance.client_triggered_event,
      'phone_number': instance.phone_number,
      'user_name': instance.user_name,
      'last_user_name': instance.last_user_name,
      'referral_code': instance.referral_code,
      'gender': instance.gender,
      'email': instance.email,
      'version_number': instance.version_number,
      'version_build_number': instance.version_build_number,
      'num_direct_children': instance.num_direct_children,
      'num_total_children': instance.num_total_children,
      'last_read_current_balance': instance.last_read_current_balance,
      'last_read_total_children': instance.last_read_total_children,
      'datetime_version_date':
          FirebaseDocument.DateTimeToJson(instance.datetime_version_date),
      'last_checked_version_number': instance.last_checked_version_number,
      'last_checked_version_datetime': FirebaseDocument.DateTimeToJson(
          instance.last_checked_version_datetime),
      'last_checked_build_number': instance.last_checked_build_number,
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
      'car_type': instance.car_type,
      'profile_status': instance.profile_status,
      'car_color': instance.car_color,
      'car_number': instance.car_number,
      'car_model': instance.car_model,
      'driver_rating': instance.driver_rating,
      'num_rating': instance.num_rating,
      'link_img_common_profile': instance.link_img_common_profile,
      'img_status_common_profile': instance.img_status_common_profile,
      'link_img_common_libre': instance.link_img_common_libre,
      'img_status_common_libre': instance.img_status_common_libre,
      'link_img_common_driving_license':
          instance.link_img_common_driving_license,
      'img_status_common_driving_license':
          instance.img_status_common_driving_license,
      'link_img_common_insurance': instance.link_img_common_insurance,
      'img_status_common_insurance': instance.img_status_common_insurance,
      'is_representative': instance.is_representative,
      'link_img_common_representative': instance.link_img_common_representative,
      'img_status_common_representative':
          instance.img_status_common_representative,
      'link_img_code_3_tin_number': instance.link_img_code_3_tin_number,
      'img_status_code_3_tin_number': instance.img_status_code_3_tin_number,
      'link_img_code_3_business_license':
          instance.link_img_code_3_business_license,
      'img_status_code_3_business_license':
          instance.img_status_code_3_business_license,
      'link_img_code_1_mahiber_wul': instance.link_img_code_1_mahiber_wul,
      'img_status_code_1_mahiber_wul': instance.img_status_code_1_mahiber_wul,
    };
