// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_version_and_update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenVersionAndUpdateInfo _$TokenVersionAndUpdateInfoFromJson(
        Map<String, dynamic> json) =>
    TokenVersionAndUpdateInfo()
      ..device_token = json['dt'] as String
      ..version_number = json['vn'] as String
      ..build_number = json['bn'] as int
      ..last_update_timestamp = json['lu'] as int?
      ..client_triggered_event = json['cte'] as bool?
      ..optional_update_available = json['oua'] as bool?
      ..forceful_update_available = json['fua'] as bool?;

Map<String, dynamic> _$TokenVersionAndUpdateInfoToJson(
    TokenVersionAndUpdateInfo instance) {
  final val = <String, dynamic>{
    'dt': instance.device_token,
    'vn': instance.version_number,
    'bn': instance.build_number,
    'lu': FirebaseDocument.EmptyServerTimeStampFiller(
        instance.last_update_timestamp),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('cte', instance.client_triggered_event);
  writeNotNull('oua', instance.optional_update_available);
  writeNotNull('fua', instance.forceful_update_available);
  return val;
}
