// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideRequest _$RideRequestFromJson(Map<String, dynamic> json) {
  return RideRequest()
    ..client_triggered_event = json['client_triggered_event'] as bool?
    ..ride_status = json['ride_status'] as int
    ..cancel_source = json['cancel_source'] as int?
    ..cancel_source_trigger_source_id =
        json['cancel_source_trigger_source_id'] as String?
    ..cancel_code = json['cancel_code'] as int?
    ..cancel_reason = json['cancel_reason'] as String?
    ..customer_id = json['customer_id'] as String?
    ..customer_name = json['customer_name'] as String
    ..customer_phone = json['customer_phone'] as String
    ..customer_device_token = json['customer_device_token'] as String?
    ..customer_email = json['customer_email'] as String?
    ..pickup_location = FirebaseDocument.LatLngFromJson(json['pickup_location'])
    ..pickup_address_name = json['pickup_address_name'] as String
    ..dropoff_location =
        FirebaseDocument.LatLngFromJson(json['dropoff_location'])
    ..dropoff_address_name = json['dropoff_address_name'] as String
    ..date_ride_created =
        FirebaseDocument.DateTimeFromJson(json['date_ride_created'])
    ..is_scheduled = json['is_scheduled'] as bool?
    ..scheduled_after_seconds = json['scheduled_after_seconds'] as int?
    ..driver_id = json['driver_id'] as String?
    ..driver_name = json['driver_name'] as String?
    ..driver_phone = json['driver_phone'] as String?
    ..driver_device_token = json['driver_device_token'] as String?
    ..driver_to_pickup_distance_meters = FirebaseDocument.DoubleFromJson(
        json['driver_to_pickup_distance_meters'])
    ..driver_to_pickup_distance_str =
        json['driver_to_pickup_distance_str'] as String?
    ..driver_to_pickup_duration_seconds = FirebaseDocument.DoubleFromJson(
        json['driver_to_pickup_duration_seconds'])
    ..driver_to_pickup_duration_str =
        json['driver_to_pickup_duration_str'] as String?
    ..driver_to_pickup_encoded_points =
        json['driver_to_pickup_encoded_points'] as String?
    ..estimated_fare = FirebaseDocument.DoubleFromJson(json['estimated_fare'])
    ..actual_pickup_location =
        FirebaseDocument.LatLngFromJson(json['actual_pickup_location'])
    ..actual_dropoff_location =
        FirebaseDocument.LatLngFromJson(json['actual_dropoff_location'])
    ..actual_pickup_to_initial_dropoff_encoded_points =
        json['actual_pickup_to_initial_dropoff_encoded_points'] as String?
    ..car_model = json['car_model'] as String?
    ..car_color = json['car_color'] as String?
    ..car_number = json['car_number'] as String?
    ..trigger_source_driver_id = json['trigger_source_driver_id'] as String?
    ..base_fare = FirebaseDocument.DoubleFromJson(json['base_fare'])
    ..actual_trip_fare =
        FirebaseDocument.DoubleFromJson(json['actual_trip_fare'])
    ..actual_trip_minutes =
        FirebaseDocument.DoubleFromJson(json['actual_trip_minutes'])
    ..actual_trip_kilometers =
        FirebaseDocument.DoubleFromJson(json['actual_trip_kilometers']);
}

Map<String, dynamic> _$RideRequestToJson(RideRequest instance) =>
    <String, dynamic>{
      'client_triggered_event': instance.client_triggered_event,
      'ride_status': instance.ride_status,
      'cancel_source': instance.cancel_source,
      'cancel_source_trigger_source_id':
          instance.cancel_source_trigger_source_id,
      'cancel_code': instance.cancel_code,
      'cancel_reason': instance.cancel_reason,
      'customer_id': instance.customer_id,
      'customer_name': instance.customer_name,
      'customer_phone': instance.customer_phone,
      'customer_device_token': instance.customer_device_token,
      'customer_email': instance.customer_email,
      'pickup_location':
          FirebaseDocument.LatLngToJson(instance.pickup_location),
      'pickup_address_name': instance.pickup_address_name,
      'dropoff_location':
          FirebaseDocument.LatLngToJson(instance.dropoff_location),
      'dropoff_address_name': instance.dropoff_address_name,
      'date_ride_created':
          FirebaseDocument.DateTimeToJson(instance.date_ride_created),
      'is_scheduled': instance.is_scheduled,
      'scheduled_after_seconds': instance.scheduled_after_seconds,
      'driver_id': instance.driver_id,
      'driver_name': instance.driver_name,
      'driver_phone': instance.driver_phone,
      'driver_device_token': instance.driver_device_token,
      'driver_to_pickup_distance_meters':
          instance.driver_to_pickup_distance_meters,
      'driver_to_pickup_distance_str': instance.driver_to_pickup_distance_str,
      'driver_to_pickup_duration_seconds':
          instance.driver_to_pickup_duration_seconds,
      'driver_to_pickup_duration_str': instance.driver_to_pickup_duration_str,
      'driver_to_pickup_encoded_points':
          instance.driver_to_pickup_encoded_points,
      'estimated_fare': instance.estimated_fare,
      'actual_pickup_location':
          FirebaseDocument.LatLngToJson(instance.actual_pickup_location),
      'actual_dropoff_location':
          FirebaseDocument.LatLngToJson(instance.actual_dropoff_location),
      'actual_pickup_to_initial_dropoff_encoded_points':
          instance.actual_pickup_to_initial_dropoff_encoded_points,
      'car_model': instance.car_model,
      'car_color': instance.car_color,
      'car_number': instance.car_number,
      'trigger_source_driver_id': instance.trigger_source_driver_id,
      'base_fare': instance.base_fare,
      'actual_trip_fare': instance.actual_trip_fare,
      'actual_trip_minutes': instance.actual_trip_minutes,
      'actual_trip_kilometers': instance.actual_trip_kilometers,
    };
