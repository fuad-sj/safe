// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_ride_customer_loc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedRideCustomerLocDetails _$SharedRideCustomerLocDetailsFromJson(
        Map<String, dynamic> json) =>
    SharedRideCustomerLocDetails()
      ..evaluating_ride_id = json['evaluating_ride_id'] as String?
      ..evaluating_dest_place_id = json['evaluating_dest_place_id'] as String?
      ..is_loc_valid = json['is_loc_valid'] as bool?
      ..compass_orientation = (json['compass_orientation'] as num?)?.toDouble()
      ..last_update_timestamp = json['last_update_timestamp'] as int?;

Map<String, dynamic> _$SharedRideCustomerLocDetailsToJson(
        SharedRideCustomerLocDetails instance) =>
    <String, dynamic>{
      'evaluating_ride_id': instance.evaluating_ride_id,
      'evaluating_dest_place_id': instance.evaluating_dest_place_id,
      'is_loc_valid': instance.is_loc_valid,
      'compass_orientation': instance.compass_orientation,
      'last_update_timestamp': instance.last_update_timestamp,
    };
