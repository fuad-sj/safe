import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe/models/firebase_document.dart';

part 'shared_ride_broadcast.g.dart';

class SharedRideBroadcast {
  static const String SHARED_RIDE_DATABASE_ROOT =
      "https://safetransports-et-2995d.firebaseio.com/";

  static const KEY_LOCATION = "l";
  static const KEY_DETAILS = "dt";

  static const FIELD_BROADCAST_LOC = "broadcast_loc";

  String? ride_id;

  LatLng? broadcast_loc;

  SharedRideDetails? ride_details;

  // This is a computed value, not stored.
  double? distance_to_broadcast;

  SharedRideBroadcast();

  factory SharedRideBroadcast.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map;

    return SharedRideBroadcast.fromMap(data, snapshot.key!);
  }

  factory SharedRideBroadcast.fromMap(Map data, String? ride_id) {
    var coords =
        data.containsKey(KEY_LOCATION) ? (data[KEY_LOCATION] as List) : null;
    var broadcast_loc = coords != null ? LatLng(coords[0], coords[1]) : null;

    var details =
        data.containsKey(KEY_DETAILS) ? (data[KEY_DETAILS] as Map) : Map();

    return SharedRideBroadcast()
      ..ride_id = ride_id
      ..broadcast_loc = broadcast_loc
      ..ride_details =
          _$SharedRideDetailsFromJson(details as Map<String, dynamic>);
  }

  bool isValidOrderToConsider() {
    if (ride_details == null ||
        (ride_details!.is_broadcast_launched ?? false) != true) {
      return false;
    }

    if ((ride_details!.is_stale_order ?? false) == true ||
        (ride_details!.is_trip_cancelled ?? false) == true ||
        (ride_details!.is_trip_started ?? false) == true ||
        (ride_details!.is_fully_booked ?? false) == true) {
      return false;
    }

    return true;
  }
}

@JsonSerializable()
class SharedRideDetails {
  static const FIELD_PLACE_NAME = "place_name";
  static const FIELD_PLACE_ID = "place_id";
  static const FIELD_PLACE_LOC = "place_loc";
  static const FIELD_INITIAL_LOC = "initial_loc";

  static const FIELD_CREATED_TIMESTAMP = "created_timestamp";
  static const FIELD_PING_TIMESTAMP = "ping_timestamp";
  static const FIELD_TRIP_STARTED_TIMESTAMP = "trip_started_timestamp";

  static const FIELD_DRIVER_NAME = "driver_name";
  static const FIELD_DRIVER_PHONE = "driver_phone";
  static const FIELD_CAR_PLATE = "car_plate";
  static const FIELD_CAR_DETAILS = "car_details";
  static const FIELD_IS_SIX_SEATER = "is_six_seater";

  static const FIELD_EST_PRICE = "est_price";
  static const FIELD_DISTANCE_KM = "distance_km";
  static const FIELD_DURATION_MINUTES = "duration_minutes";

  static const FIELD_IS_PRICE_CALCULATED = "is_price_calculated";
  static const FIELD_IS_ORDER_CONFIRMED = "is_order_confirmed";
  static const FIELD_IS_BROADCAST_LAUNCHED = "is_broadcast_launched";
  static const FIELD_IS_TRIP_CANCELLED = "is_trip_cancelled";
  static const FIELD_IS_STALE_ORDER = "is_stale_order";
  static const FIELD_IS_FULLY_BOOKED = "is_fully_booked";
  static const FIELD_IS_TRIP_STARTED = "is_trip_started";
  static const FIELD_IS_TRIP_COMPLETED = "is_trip_completed";

  static const FIELD_IS_FORCEFULLY_FILLED = "is_forcefully_filled";
  static const FIELD_NUM_FORCEFUL_FILLED = "num_forceful_filled";

  static const FIELD_SEATS_REMAINING = "seats_remaining";

  static const FIELD_REACHED_OUT_CUSTOMERS = "reached_out_customers";

  static const FIELD_ACCEPTED_CUSTOMERS = "accepted_customers";

  static const FIELD_SEPARATE_DROPOFFS = "separate_dropoffs";

  //

  bool? client_triggered_event;
  bool? is_unread_data;

  String? place_name;
  String? place_id;

  @JsonKey(
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? place_loc;
  @JsonKey(
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? initial_loc;

  int? created_timestamp;
  int? ping_timestamp;
  int? trip_started_timestamp;

  String? driver_name;
  String? driver_phone;
  String? car_plate;
  String? car_details;
  bool? is_six_seater;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? est_price;
  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? distance_km;
  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? duration_minutes;

  bool? is_price_calculated;
  bool? is_order_confirmed;
  bool? is_broadcast_launched;
  bool? is_trip_cancelled;
  bool? is_stale_order;
  bool? is_fully_booked;
  bool? is_trip_started;
  bool? is_trip_completed;

  bool? is_forcefully_filled;
  int? num_forceful_filled;

  int? seats_remaining;

  @JsonKey(
      fromJson: SharedRideReachOutCustomer.List_FromJson,
      toJson: SharedRideReachOutCustomer.List_ToJson)
  List<SharedRideReachOutCustomer>? reached_out_customers;

  @JsonKey(
      fromJson: SharedRideAcceptedCustomer.List_FromJson,
      toJson: SharedRideAcceptedCustomer.List_ToJson)
  List<SharedRideAcceptedCustomer>? accepted_customers;

  @JsonKey(
      fromJson: SharedRideSeparateDropoff.List_FromJson,
      toJson: SharedRideSeparateDropoff.List_ToJson)
  List<SharedRideSeparateDropoff>? separate_dropoffs;

  SharedRideDetails();
}

List<dynamic> _ListToJson<T>(List<T>? list, Map Function(T val) converter) {
  return list?.map((e) => converter(e)).toList() as List<dynamic>;
}

dynamic _ListFromJson<T>(
    dynamic json, T Function(Map<String, dynamic>) converter) {
  if (json == null) return null;
  return (json as List<dynamic>?)?.map((e) => converter(e)).toList();
}

@JsonSerializable()
class SharedRideReachOutCustomer {
  late String customer_phone;
  late String customer_id;

  SharedRideReachOutCustomer();

  static List<dynamic> List_ToJson(List<SharedRideReachOutCustomer>? list) =>
      _ListToJson(list, _$SharedRideReachOutCustomerToJson);

  static dynamic List_FromJson(List<SharedRideReachOutCustomer>? list) =>
      _ListFromJson(list, _$SharedRideReachOutCustomerFromJson);
}

@JsonSerializable()
class SharedRideAcceptedCustomer {
  late String customer_phone;
  late String customer_id;

  late int num_customers;

  SharedRideAcceptedCustomer();

  static List<dynamic> List_ToJson(List<SharedRideAcceptedCustomer>? list) =>
      _ListToJson(list, _$SharedRideAcceptedCustomerToJson);

  static dynamic List_FromJson(List<SharedRideAcceptedCustomer>? list) =>
      _ListFromJson(list, _$SharedRideAcceptedCustomerFromJson);
}

@JsonSerializable()
class SharedRideSeparateDropoff {
  late String customer_phone;
  late String customer_id;

  late int num_customers;

  late List<double> dropoff_loc;

  static List<dynamic> List_ToJson(List<SharedRideSeparateDropoff>? list) =>
      _ListToJson(list, _$SharedRideSeparateDropoffToJson);

  static dynamic List_FromJson(List<SharedRideSeparateDropoff>? list) =>
      _ListFromJson(list, _$SharedRideSeparateDropoffFromJson);
}

@JsonSerializable()
class SharedRideDropoffPrice {
  late String customer_phone;
  late String customer_id;

  late int num_customers;

  late double travelled_km;
  late double travelled_time;

  late double each_price;
  late double total_price;

  late int dropoff_timestamp;
}
