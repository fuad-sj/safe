// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer()
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
            .toList();
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'phone_number': instance.phone_number,
      'user_name': instance.user_name,
      'date_created': FirebaseDocument.DateTimeToJson(instance.date_created),
      'date_last_login':
          FirebaseDocument.DateTimeToJson(instance.date_last_login),
      'is_active': instance.is_active,
      'is_logged_in': instance.is_logged_in,
      'device_registration_tokens': instance.device_registration_tokens,
    };
