import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe/models/firebase_document.dart';

class SharedRideBroadcast {
  static const String SHARED_RIDE_DATABASE_ROOT =
      "https://safetransports-et-2995d.firebaseio.com/";

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

  String? ride_id;

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

  List<SharedRideReachOutCustomer>? reached_out_customers;

  List<SharedRideAcceptedCustomer>? accepted_customers;

  List<SharedRideSeparateDropoff>? separate_dropoffs;

  /**
   * This is a computed value, not stored ANYWHERE. but useful in comparing different broadcasts
   */
  double? distance_to_broadcast;

  bool isValidOrderToConsider() {
    if ((is_broadcast_launched ?? false) != true) {
      return false;
    }

    if ((is_stale_order ?? false) == true ||
        (is_trip_cancelled ?? false) == true ||
        (is_trip_started ?? false) == true ||
        (is_fully_booked ?? false) == true) {
      return false;
    }

    return true;
  }

  SharedRideBroadcast();

  factory SharedRideBroadcast.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map;

    return SharedRideBroadcast.fromMap(data, snapshot.key!);
  }

  factory SharedRideBroadcast.fromMap(Map data, String ride_id) {
    return SharedRideBroadcast()
      ..ride_id = ride_id ?? null
      ..place_name = data["place_name"] ?? null
      ..place_id = data["place_id"] ?? null
      ..place_loc = LatLng.fromJson(data["place_loc"]) ?? null
      ..initial_loc = LatLng.fromJson(data["initial_loc"]) ?? null
      ..created_timestamp = data["created_timestamp"] ?? null
      ..ping_timestamp = data["ping_timestamp"] ?? null
      ..trip_started_timestamp = data["trip_started_timestamp"] ?? null
      ..driver_name = data["driver_name"] ?? null
      ..driver_phone = data["driver_phone"] ?? null
      ..car_plate = data["car_plate"] ?? null
      ..car_details = data["car_details"] ?? null
      ..is_six_seater = data["is_six_seater"] ?? null
      ..est_price = (data["est_price"] ?? 0) + 0.0 ?? null
      ..is_price_calculated = data["is_price_calculated"] ?? null
      ..is_order_confirmed = data["is_order_confirmed"] ?? null
      ..is_broadcast_launched = data["is_broadcast_launched"] ?? null
      ..is_trip_cancelled = data["is_trip_cancelled"] ?? null
      ..is_stale_order = data["is_stale_order"] ?? null
      ..is_fully_booked = data["is_fully_booked"] ?? null
      ..is_trip_started = data["is_trip_started"] ?? null
      ..is_trip_completed = data["is_trip_completed"] ?? null
      ..is_forcefully_filled = data["is_forcefully_filled"] ?? null
      ..num_forceful_filled = data["num_forceful_filled"] ?? null
      ..seats_remaining = data["seats_remaining"] ?? null
      ..reached_out_customers =
          (data['reached_out_customers'] as List<dynamic>?)
              ?.map((e) => SharedRideReachOutCustomer()
                ..customer_phone = e['customer_phone'] as String
                ..customer_id = e['customer_id'] as String)
              .toList()
      ..accepted_customers = (data['accepted_customers'] as List<dynamic>?)
          ?.map((e) => SharedRideAcceptedCustomer()
            ..customer_phone = e['customer_phone'] as String
            ..customer_id = e['customer_id'] as String
            ..num_customers = e['num_customers'] as int)
          .toList()
      ..separate_dropoffs = (data['separate_dropoffs'] as List<dynamic>?)
          ?.map((e) => SharedRideSeparateDropoff()
            ..customer_phone = e['customer_phone'] as String
            ..customer_id = e['customer_id'] as String
            ..num_customers = e['num_customers'] as int
            ..dropoff_loc = (e['dropoff_loc'] as List<dynamic>)
                .map((e) => (e as num).toDouble())
                .toList())
          .toList();
  }

  static List<dynamic> SharedRideReachOutCustomers_ToJson(
      List<SharedRideReachOutCustomer> list) {
    return list
        .map((customer) => {
              'customer_phone': customer.customer_phone,
              'customer_id': customer.customer_id,
            })
        .toList();
  }

  static List<dynamic> SharedRideAcceptedCustomer_ToJson(
      List<SharedRideAcceptedCustomer> list) {
    return list
        .map((customer) => {
              'customer_phone': customer.customer_phone,
              'customer_id': customer.customer_id,
              'num_customers': customer.num_customers,
            })
        .toList();
  }

  static List<dynamic> SharedRideSeparateDropoff_ToJson(
      List<SharedRideSeparateDropoff> list) {
    return list
        .map((customer) => {
              'customer_phone': customer.customer_phone,
              'customer_id': customer.customer_id,
              'num_customers': customer.num_customers,
              'dropoff_loc': [customer.dropoff_loc[0], customer.dropoff_loc[1]]
            })
        .toList();
  }
}

class SharedRideReachOutCustomer {
  late String customer_phone;
  late String customer_id;

  SharedRideReachOutCustomer();
}

class SharedRideAcceptedCustomer {
  late String customer_phone;
  late String customer_id;

  late int num_customers;

  SharedRideAcceptedCustomer();
}

class SharedRideSeparateDropoff {
  late String customer_phone;
  late String customer_id;

  late int num_customers;

  late List<double> dropoff_loc;
}

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

class SharedRideLocation {
  String? ride_id;

  // these 2 fields are filled from another place
  double? latitude;
  double? longitude;

  SharedRideLocation({
    this.ride_id,
    this.latitude,
    this.longitude,
  });

  factory SharedRideLocation.fromSnapshot(DataSnapshot snapshot) {
    String rideId = snapshot.key!;

    var data = snapshot.value as Map;

    var coords = data["l"] as List;
    double lat = coords[0];
    double lng = coords[1];

    return SharedRideLocation(
      ride_id: rideId,
      latitude: lat,
      longitude: lng,
    );
  }
}

class SharedRidePlaceAggregate {
  String place_id;
  String place_name;

  double? four_seater_est_price;
  double? six_seater_est_price;

  Set<String> all_four_seater_rides;
  Set<String> all_six_seater_rides;

  List<String> nearby_four_seater_rides;
  List<String> nearby_six_seater_rides;

  Set<String> prev_seen_nearby_four_seater_rides;
  Set<String> prev_seen_nearby_six_seater_rides;

  SharedRidePlaceAggregate({
    required this.place_id,
    required this.place_name,
  })  : all_four_seater_rides = Set(),
        all_six_seater_rides = Set(),
        prev_seen_nearby_four_seater_rides = Set(),
        prev_seen_nearby_six_seater_rides = Set(),
        nearby_four_seater_rides = [],
        nearby_six_seater_rides = [];
}
