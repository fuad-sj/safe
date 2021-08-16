// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) {
  return Driver()
    ..phone_number = json['phone_number'] as String?
    ..user_name = json['user_name'] as String?
    ..date_created = FirebaseDocument.DateTimeFromJson(json['date_created'])
    ..date_last_login =
        FirebaseDocument.DateTimeFromJson(json['date_last_login'])
    ..is_active = json['is_active'] as bool? ?? true
    ..is_logged_in = json['is_logged_in'] as bool? ?? false
    ..device_registration_tokens =
        (json['device_registration_tokens'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList()
    ..driver_type = json['driver_type'] as int?
    ..profile_status = json['profile_status'] as int?
    ..car_color = json['car_color'] as String?
    ..car_number = json['car_number'] as String?
    ..car_model = json['car_model'] as String?
    ..is_driver_online = json['is_driver_online'] as bool?
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
    ..img_status_code_3_tin_number =
        json['img_status_code_3_tin_number'] as int?
    ..link_img_code_3_business_license =
        json['link_img_code_3_business_license'] as String?
    ..img_status_code_3_business_license =
        json['img_status_code_3_business_license'] as int?
    ..link_img_code_1_mahiber_wul =
        json['link_img_code_1_mahiber_wul'] as String?
    ..img_status_code_1_mahiber_wul =
        json['img_status_code_1_mahiber_wul'] as int?;
}

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
      'phone_number': instance.phone_number,
      'user_name': instance.user_name,
      'date_created': FirebaseDocument.DateTimeToJson(instance.date_created),
      'date_last_login':
          FirebaseDocument.DateTimeToJson(instance.date_last_login),
      'is_active': instance.is_active,
      'is_logged_in': instance.is_logged_in,
      'device_registration_tokens': instance.device_registration_tokens,
      'driver_type': instance.driver_type,
      'profile_status': instance.profile_status,
      'car_color': instance.car_color,
      'car_number': instance.car_number,
      'car_model': instance.car_model,
      'is_driver_online': instance.is_driver_online,
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