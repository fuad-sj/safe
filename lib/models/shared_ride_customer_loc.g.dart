// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_ride_customer_loc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedRideCustomerLocDetails _$SharedRideCustomerLocDetailsFromJson(
        Map<String, dynamic> json) =>
    SharedRideCustomerLocDetails()
      ..evaluating_ride_id = json['eri'] as String?
      ..evaluating_dest_place_id = json['edpi'] as String?
      ..is_loc_valid = json['ilv'] as bool?
      ..compass_orientation = (json['co'] as num?)?.toDouble()
      ..last_update_timestamp = json['lut'] as int?;

Map<String, dynamic> _$SharedRideCustomerLocDetailsToJson(
    SharedRideCustomerLocDetails instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('eri', instance.evaluating_ride_id);
  writeNotNull('edpi', instance.evaluating_dest_place_id);
  writeNotNull('ilv', instance.is_loc_valid);
  writeNotNull('co', instance.compass_orientation);
  writeNotNull('lut', instance.last_update_timestamp);
  return val;
}

SharedRideCustomerRequestNearbyDriver
    _$SharedRideCustomerRequestNearbyDriverFromJson(
            Map<String, dynamic> json) =>
        SharedRideCustomerRequestNearbyDriver()
          ..request_loc = FirebaseDocument.LatLngFromJson(json['rloc'])
          ..customer_device_token = json['cdt'] as String?
          ..destination_place_name = json['dpn'] as String?
          ..destination_place_id = json['dpi'] as String?
          ..last_update_timestamp = json['lut'] as int?;

Map<String, dynamic> _$SharedRideCustomerRequestNearbyDriverToJson(
    SharedRideCustomerRequestNearbyDriver instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('rloc', FirebaseDocument.LatLngToJson(instance.request_loc));
  writeNotNull('cdt', instance.customer_device_token);
  writeNotNull('dpn', instance.destination_place_name);
  writeNotNull('dpi', instance.destination_place_id);
  writeNotNull('lut', instance.last_update_timestamp);
  return val;
}
