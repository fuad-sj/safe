// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_ride_broadcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedRideDetails _$SharedRideDetailsFromJson(Map<String, dynamic> json) =>
    SharedRideDetails()
      ..client_triggered_event = json['client_triggered_event'] as bool?
      ..is_unread_data = json['is_unread_data'] as bool?
      ..place_name = json['place_name'] as String?
      ..place_id = json['place_id'] as String?
      ..place_loc = FirebaseDocument.LatLngFromJson(json['place_loc'])
      ..initial_loc = FirebaseDocument.LatLngFromJson(json['initial_loc'])
      ..created_timestamp = json['created_timestamp'] as int?
      ..ping_timestamp = json['ping_timestamp'] as int?
      ..trip_started_timestamp = json['trip_started_timestamp'] as int?
      ..driver_name = json['driver_name'] as String?
      ..driver_phone = json['driver_phone'] as String?
      ..car_plate = json['car_plate'] as String?
      ..car_details = json['car_details'] as String?
      ..is_six_seater = json['is_six_seater'] as bool?
      ..est_price = FirebaseDocument.DoubleFromJson(json['est_price'])
      ..distance_km = FirebaseDocument.DoubleFromJson(json['distance_km'])
      ..duration_minutes =
          FirebaseDocument.DoubleFromJson(json['duration_minutes'])
      ..is_price_calculated = json['is_price_calculated'] as bool?
      ..is_order_confirmed = json['is_order_confirmed'] as bool?
      ..is_broadcast_launched = json['is_broadcast_launched'] as bool?
      ..is_trip_cancelled = json['is_trip_cancelled'] as bool?
      ..is_stale_order = json['is_stale_order'] as bool?
      ..is_fully_booked = json['is_fully_booked'] as bool?
      ..is_trip_started = json['is_trip_started'] as bool?
      ..is_trip_completed = json['is_trip_completed'] as bool?
      ..is_forcefully_filled = json['is_forcefully_filled'] as bool?
      ..num_forceful_filled = json['num_forceful_filled'] as int?
      ..seats_remaining = json['seats_remaining'] as int?
      ..reached_out_customers = SharedRideReachOutCustomer.List_FromJson(
          json['reached_out_customers'] as List<SharedRideReachOutCustomer>?)
      ..accepted_customers = SharedRideAcceptedCustomer.List_FromJson(
          json['accepted_customers'] as List<SharedRideAcceptedCustomer>?)
      ..separate_dropoffs = SharedRideSeparateDropoff.List_FromJson(
          json['separate_dropoffs'] as List<SharedRideSeparateDropoff>?);

Map<String, dynamic> _$SharedRideDetailsToJson(SharedRideDetails instance) =>
    <String, dynamic>{
      'client_triggered_event': instance.client_triggered_event,
      'is_unread_data': instance.is_unread_data,
      'place_name': instance.place_name,
      'place_id': instance.place_id,
      'place_loc': FirebaseDocument.LatLngToJson(instance.place_loc),
      'initial_loc': FirebaseDocument.LatLngToJson(instance.initial_loc),
      'created_timestamp': instance.created_timestamp,
      'ping_timestamp': instance.ping_timestamp,
      'trip_started_timestamp': instance.trip_started_timestamp,
      'driver_name': instance.driver_name,
      'driver_phone': instance.driver_phone,
      'car_plate': instance.car_plate,
      'car_details': instance.car_details,
      'is_six_seater': instance.is_six_seater,
      'est_price': instance.est_price,
      'distance_km': instance.distance_km,
      'duration_minutes': instance.duration_minutes,
      'is_price_calculated': instance.is_price_calculated,
      'is_order_confirmed': instance.is_order_confirmed,
      'is_broadcast_launched': instance.is_broadcast_launched,
      'is_trip_cancelled': instance.is_trip_cancelled,
      'is_stale_order': instance.is_stale_order,
      'is_fully_booked': instance.is_fully_booked,
      'is_trip_started': instance.is_trip_started,
      'is_trip_completed': instance.is_trip_completed,
      'is_forcefully_filled': instance.is_forcefully_filled,
      'num_forceful_filled': instance.num_forceful_filled,
      'seats_remaining': instance.seats_remaining,
      'reached_out_customers': SharedRideReachOutCustomer.List_ToJson(
          instance.reached_out_customers),
      'accepted_customers':
          SharedRideAcceptedCustomer.List_ToJson(instance.accepted_customers),
      'separate_dropoffs':
          SharedRideSeparateDropoff.List_ToJson(instance.separate_dropoffs),
    };

SharedRideReachOutCustomer _$SharedRideReachOutCustomerFromJson(
        Map<String, dynamic> json) =>
    SharedRideReachOutCustomer()
      ..customer_phone = json['customer_phone'] as String
      ..customer_id = json['customer_id'] as String;

Map<String, dynamic> _$SharedRideReachOutCustomerToJson(
        SharedRideReachOutCustomer instance) =>
    <String, dynamic>{
      'customer_phone': instance.customer_phone,
      'customer_id': instance.customer_id,
    };

SharedRideAcceptedCustomer _$SharedRideAcceptedCustomerFromJson(
        Map<String, dynamic> json) =>
    SharedRideAcceptedCustomer()
      ..customer_phone = json['customer_phone'] as String
      ..customer_id = json['customer_id'] as String
      ..num_customers = json['num_customers'] as int;

Map<String, dynamic> _$SharedRideAcceptedCustomerToJson(
        SharedRideAcceptedCustomer instance) =>
    <String, dynamic>{
      'customer_phone': instance.customer_phone,
      'customer_id': instance.customer_id,
      'num_customers': instance.num_customers,
    };

SharedRideSeparateDropoff _$SharedRideSeparateDropoffFromJson(
        Map<String, dynamic> json) =>
    SharedRideSeparateDropoff()
      ..customer_phone = json['customer_phone'] as String
      ..customer_id = json['customer_id'] as String
      ..num_customers = json['num_customers'] as int
      ..dropoff_loc = (json['dropoff_loc'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();

Map<String, dynamic> _$SharedRideSeparateDropoffToJson(
        SharedRideSeparateDropoff instance) =>
    <String, dynamic>{
      'customer_phone': instance.customer_phone,
      'customer_id': instance.customer_id,
      'num_customers': instance.num_customers,
      'dropoff_loc': instance.dropoff_loc,
    };

SharedRideDropoffPrice _$SharedRideDropoffPriceFromJson(
        Map<String, dynamic> json) =>
    SharedRideDropoffPrice()
      ..customer_phone = json['customer_phone'] as String
      ..customer_id = json['customer_id'] as String
      ..num_customers = json['num_customers'] as int
      ..travelled_km = (json['travelled_km'] as num).toDouble()
      ..travelled_time = (json['travelled_time'] as num).toDouble()
      ..each_price = (json['each_price'] as num).toDouble()
      ..total_price = (json['total_price'] as num).toDouble()
      ..dropoff_timestamp = json['dropoff_timestamp'] as int;

Map<String, dynamic> _$SharedRideDropoffPriceToJson(
        SharedRideDropoffPrice instance) =>
    <String, dynamic>{
      'customer_phone': instance.customer_phone,
      'customer_id': instance.customer_id,
      'num_customers': instance.num_customers,
      'travelled_km': instance.travelled_km,
      'travelled_time': instance.travelled_time,
      'each_price': instance.each_price,
      'total_price': instance.total_price,
      'dropoff_timestamp': instance.dropoff_timestamp,
    };
