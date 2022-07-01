// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sys_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SysConfig _$SysConfigFromJson(Map<String, dynamic> json) => SysConfig()
  ..rate_normal_base_fare =
      FirebaseDocument.DoubleFromJson(json['rate_normal_base_fare'])
  ..rate_normal_per_km_charge =
      FirebaseDocument.DoubleFromJson(json['rate_normal_per_km_charge'])
  ..rate_normal_per_minute_charge =
      FirebaseDocument.DoubleFromJson(json['rate_normal_per_minute_charge'])
  ..search_radius = FirebaseDocument.DoubleFromJson(json['search_radius']);

Map<String, dynamic> _$SysConfigToJson(SysConfig instance) => <String, dynamic>{
      'rate_normal_base_fare': instance.rate_normal_base_fare,
      'rate_normal_per_km_charge': instance.rate_normal_per_km_charge,
      'rate_normal_per_minute_charge': instance.rate_normal_per_minute_charge,
      'search_radius': instance.search_radius,
    };
