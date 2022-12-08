// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_otp_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SafeOTPRequest _$SafeOTPRequestFromJson(Map<String, dynamic> json) =>
    SafeOTPRequest()
      ..otp_status = json['otp_status'] as int?
      ..phone_number = json['phone_number'] as String?
      ..auth_phone_id = json['auth_phone_id'] as String?
      ..otp_code = json['otp_code'] as String?;

Map<String, dynamic> _$SafeOTPRequestToJson(SafeOTPRequest instance) =>
    <String, dynamic>{
      'otp_status': instance.otp_status,
      'phone_number': instance.phone_number,
      'auth_phone_id': instance.auth_phone_id,
      'otp_code': instance.otp_code,
    };
