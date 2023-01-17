// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateVersion _$UpdateVersionFromJson(Map<String, dynamic> json) =>
    UpdateVersion()
      ..version_number = json['version_number'] as String?
      ..build_number = json['build_number'] as int?
      ..is_customer_app = json['is_customer_app'] as bool?
      ..is_forceful_update = json['is_forceful_update'] as bool?
      ..date_version_created =
          FirebaseDocument.DateTimeFromJson(json['date_version_created']);

Map<String, dynamic> _$UpdateVersionToJson(UpdateVersion instance) =>
    <String, dynamic>{
      'version_number': instance.version_number,
      'build_number': instance.build_number,
      'is_customer_app': instance.is_customer_app,
      'is_forceful_update': instance.is_forceful_update,
      'date_version_created':
          FirebaseDocument.DateTimeToJson(instance.date_version_created),
    };
