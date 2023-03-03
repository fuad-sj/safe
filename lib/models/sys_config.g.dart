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
  ..rate_normal_fair_per_km_charge =
      FirebaseDocument.DoubleFromJson(json['rate_normal_fair_per_km_charge'])
  ..rate_normal_fair_per_minute_charge = FirebaseDocument.DoubleFromJson(
      json['rate_normal_fair_per_minute_charge'])
  ..search_radius = FirebaseDocument.DoubleFromJson(json['search_radius'])
  ..customer_cashout_min_balance =
      FirebaseDocument.DoubleFromJson(json['customer_cashout_min_balance'])
  ..num_fun_update_instances = json['num_fun_update_instances'] as int?
  ..num_fun_update_check_instances =
      json['num_fun_update_check_instances'] as int?
  ..num_fun_https_cache_endpoints =
      json['num_fun_https_cache_endpoints'] as int?;

Map<String, dynamic> _$SysConfigToJson(SysConfig instance) => <String, dynamic>{
      'rate_normal_base_fare': instance.rate_normal_base_fare,
      'rate_normal_per_km_charge': instance.rate_normal_per_km_charge,
      'rate_normal_per_minute_charge': instance.rate_normal_per_minute_charge,
      'rate_normal_fair_per_km_charge': instance.rate_normal_fair_per_km_charge,
      'rate_normal_fair_per_minute_charge':
          instance.rate_normal_fair_per_minute_charge,
      'search_radius': instance.search_radius,
      'customer_cashout_min_balance': instance.customer_cashout_min_balance,
      'num_fun_update_instances': instance.num_fun_update_instances,
      'num_fun_update_check_instances': instance.num_fun_update_check_instances,
      'num_fun_https_cache_endpoints': instance.num_fun_https_cache_endpoints,
    };
