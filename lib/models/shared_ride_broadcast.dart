import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe/models/firebase_document.dart';

part 'shared_ride_broadcast.g.dart';

class SharedRideBroadcast {
  static const String SHARED_RIDE_DATABASE_ROOT =
      "https://safetransports-et-2995d.firebaseio.com/";

  static const KEY_HASH = "g";
  static const KEY_LOCATION = "l";
  static const KEY_LAT = "0";
  static const KEY_LNG = "1";
  static const KEY_DETAILS = "dt";
  static const KEY_PING = "p";

  static const FIELD_PING_TIMESTAMP = "pt";

  String? ride_id;

  LatLng? broadcast_loc;
  int? ping_timestamp;

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

    var ping = data.containsKey(KEY_PING) ? (data[KEY_PING] as Map) : Map();

    var details =
        data.containsKey(KEY_DETAILS) ? (data[KEY_DETAILS] as Map) : Map();

    return SharedRideBroadcast()
      ..ride_id = ride_id
      ..broadcast_loc = broadcast_loc
      ..ping_timestamp = ping[FIELD_PING_TIMESTAMP] ?? null
      ..ride_details =
          _$SharedRideDetailsFromJson(details.cast<String, dynamic>());
  }

  bool isValidOrderToConsider() {
    if (ride_details == null || ride_details?.order_state == null) {
      return false;
    }

    return SharedRideDetails.isBoardingState(ride_details!.order_state!);
  }

  bool isBroadcastOngoing() {
    if (!isValidOrderToConsider()) {
      return false;
    }

    if ((ride_details!.seats_remaining ?? 0) == 0) {
      return false;
    }

    return true;
  }
}

@JsonSerializable()
class SharedRideDetails {
  //#region ORDER_STATE's
  static const int STATUS_STALE = -2; // didn't receive pings in a long time
  static const int STATUS_CANCELLED = -1; // was manually cancelled

  static const int STATUS_NEW_CREATED = 1;
  static const int STATUS_ESTIMATE_CALCULATED = 2;
  static const int STATUS_ORDER_CONFIRMED = 3;
  static const int STATUS_BROADCAST_LAUNCHED = 4;
  static const int STATUS_CUSTOMERS_STARTED_BOARDING = 5;
  static const int STATUS_FULLY_BOOKED = 6;
  static const int STATUS_READY_TO_START = 7;
  static const int STATUS_TRIP_STARTED = 8;

  /**
   * to intercept customer dropoff off events(not all dropped; but a single customer). have DROP_A_CUSTOMER
   * state. driver app sets this state; backend does any necessary logging. then returns state back to TRIP_ONGOING.
   * It will cycle through this until all customers have dropped.
   */
  static const int STATUS_DROP_A_CUSTOMER = 9;
  static const int STATUS_TRIP_ONGOING = 10;

  static const int STATUS_DROPPED_ALL_CUSTOMERS = 11;
  static const int STATUS_TRIP_COMPLETED = 12;

  //#endregion

  static bool isBoardingState(int rideState) {
    switch (rideState) {
      case STATUS_BROADCAST_LAUNCHED:
      case STATUS_CUSTOMERS_STARTED_BOARDING:
        return true;
      default:
        return false;
    }
  }

  /// this is what drives the event loop, goes through the different states throughout the order lifecycle
  //#region order state and order source checking for server
  static const F_ORDER_STATE = "os";
  @JsonKey(includeIfNull: false, name: F_ORDER_STATE)
  int? order_state;
  static const F_CLIENT_TRIGGERED_EVENT = "cte";
  @JsonKey(includeIfNull: false, name: F_CLIENT_TRIGGERED_EVENT)
  bool? client_triggered_event;

  //#endregion

  //#region place details, i.e: destination
  static const F_PLACE_NAME = "pn";
  @JsonKey(includeIfNull: false, name: F_PLACE_NAME)
  String? place_name;
  static const F_PLACE_ID = "pi";
  @JsonKey(includeIfNull: false, name: F_PLACE_ID)
  String? place_id;
  static const F_PLACE_LOC = "plc";
  @JsonKey(
      includeIfNull: false,
      name: F_PLACE_LOC,
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? place_loc;

  //#endregion

  static const F_INITIAL_LOC = "il";
  @JsonKey(
      includeIfNull: false,
      name: F_INITIAL_LOC,
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? initial_loc;

  //#region timestamps for create and trip start
  static const F_CREATED_TIMESTAMP = "cts";
  @JsonKey(includeIfNull: false, name: F_CREATED_TIMESTAMP)
  int? created_timestamp;
  static const F_TRIP_STARTED_TIMESTAMP = "tsts";
  @JsonKey(includeIfNull: false, name: F_TRIP_STARTED_TIMESTAMP)
  int? trip_started_timestamp;

  //#endregion

  //#region driver details
  static const F_DRIVER_NAME = "dn";
  @JsonKey(includeIfNull: false, name: F_DRIVER_NAME)
  String? driver_name;
  static const F_DRIVER_PHONE = "dp";
  @JsonKey(includeIfNull: false, name: F_DRIVER_PHONE)
  String? driver_phone;
  static const F_CAR_PLATE = "cp";
  @JsonKey(includeIfNull: false, name: F_CAR_PLATE)
  String? car_plate;
  static const F_CAR_DETAILS = "cd";
  @JsonKey(includeIfNull: false, name: F_CAR_DETAILS)
  String? car_details;
  static const F_IS_SIX_SEATER = "iss";
  @JsonKey(includeIfNull: false, name: F_IS_SIX_SEATER)
  bool? is_six_seater;

  //#endregion

  //#region time, km + price estimates
  static const F_EST_PRICE = "ep";
  @JsonKey(
      includeIfNull: false,
      name: F_EST_PRICE,
      fromJson: FirebaseDocument.DoubleFromJson)
  double? est_price;
  static const F_DISTANCE_KM = "dk";
  @JsonKey(
      includeIfNull: false,
      name: F_DISTANCE_KM,
      fromJson: FirebaseDocument.DoubleFromJson)
  double? distance_km;
  static const F_DURATION_MINUTES = "dm";
  @JsonKey(
      includeIfNull: false,
      name: F_DURATION_MINUTES,
      fromJson: FirebaseDocument.DoubleFromJson)
  double? duration_minutes;

  //#endregion

  static const F_IS_FORCEFULLY_FILLED = "iff";
  @JsonKey(includeIfNull: false, name: F_IS_FORCEFULLY_FILLED)
  bool? is_forcefully_filled;
  static const F_NUM_FORCEFUL_FILLED = "nff";
  @JsonKey(includeIfNull: false, name: F_NUM_FORCEFUL_FILLED)
  int? num_forceful_filled;

  static const F_SEATS_REMAINING = "sr";
  @JsonKey(includeIfNull: false, name: F_SEATS_REMAINING)
  int? seats_remaining;

  static const F_REACHED_OUT_CUSTOMERS = "roc";
  @JsonKey(
      includeIfNull: false,
      name: F_REACHED_OUT_CUSTOMERS,
      fromJson: SharedRideReachOutCustomer.List_FromJson,
      toJson: SharedRideReachOutCustomer.List_ToJson)
  List<SharedRideReachOutCustomer>? reached_out_customers;

  static const F_VETTED_REACHOUT_CUSTOMERS = "vrc";
  @JsonKey(
      includeIfNull: false,
      name: F_VETTED_REACHOUT_CUSTOMERS,
      fromJson: SharedRideVettedReachoutCustomer.List_FromJson,
      toJson: SharedRideVettedReachoutCustomer.List_ToJson)
  List<SharedRideVettedReachoutCustomer>? vetted_reachout_customers;

  static const F_ACCEPTED_CUSTOMERS = "ac";
  @JsonKey(
      includeIfNull: false,
      name: F_ACCEPTED_CUSTOMERS,
      fromJson: SharedRideAcceptedCustomer.List_FromJson,
      toJson: SharedRideAcceptedCustomer.List_ToJson)
  List<SharedRideAcceptedCustomer>? accepted_customers;

  static const F_SEPARATE_DROPOFFS = "sd";
  @JsonKey(
      includeIfNull: false,
      name: F_SEPARATE_DROPOFFS,
      fromJson: SharedRideSeparateDropoff.List_FromJson,
      toJson: SharedRideSeparateDropoff.List_ToJson)
  List<SharedRideSeparateDropoff>? separate_dropoffs;

  SharedRideDetails();

  /**
   * Use this when u want to selectively update a detail field while the update is happening a node above at the broadcast level.
   * e.g:
   *
   *    if you wanna update the
   *        g: "hash"
   *        l: "location"
   *        dt:
   *            <- some field here
   */
  static String convertDetailFieldToDeepBroadcastPath(String field) {
    return SharedRideBroadcast.KEY_DETAILS + '/' + field;
  }

  factory SharedRideDetails.fromJson(Map json) =>
      _$SharedRideDetailsFromJson(json.cast<String, dynamic>());

  Map<String, dynamic> toJson() => _$SharedRideDetailsToJson(this);
}

List<dynamic>? _ListToJson<T>(List<T>? list, Map Function(T val) converter) {
  if (list == null) return null;
  return list.map((e) => converter(e)).toList() as List<dynamic>;
}

dynamic _ListFromJson<T>(
    dynamic json, T Function(Map<String, dynamic>) converter) {
  if (json == null) return null;
  return (json as List<dynamic>?)
      ?.map((e) => converter((e as Map).cast<String, dynamic>()))
      .toList();
}

dynamic _ServerTimeStampFiller(int? timestamp) {
  return timestamp ?? ServerValue.timestamp;
}

@JsonSerializable()
class SharedRideReachOutCustomer {
  @JsonKey(includeIfNull: false, name: "cp")
  late String customer_phone;
  @JsonKey(includeIfNull: false, name: "ci")
  late String customer_id;

  @JsonKey(name: "rt", toJson: _ServerTimeStampFiller)
  int? reachout_timestamp;

  SharedRideReachOutCustomer();

  static List<dynamic>? List_ToJson(List<SharedRideReachOutCustomer>? list) =>
      _ListToJson(list, _$SharedRideReachOutCustomerToJson);

  static dynamic List_FromJson(dynamic list) =>
      _ListFromJson(list, _$SharedRideReachOutCustomerFromJson);
}

@JsonSerializable()
class SharedRideVettedReachoutCustomer {
  @JsonKey(includeIfNull: false, name: "cp")
  late String customer_phone;
  @JsonKey(includeIfNull: false, name: "ci")
  late String customer_id;

  @JsonKey(name: "rt", toJson: _ServerTimeStampFiller)
  int? reachout_timestamp;

  SharedRideVettedReachoutCustomer();

  static List<dynamic>? List_ToJson(
          List<SharedRideVettedReachoutCustomer>? list) =>
      _ListToJson(list, _$SharedRideVettedReachoutCustomerToJson);

  static dynamic List_FromJson(dynamic list) =>
      _ListFromJson(list, _$SharedRideVettedReachoutCustomerFromJson);
}

@JsonSerializable()
class SharedRideAcceptedCustomer {
  @JsonKey(includeIfNull: false, name: "cp")
  late String customer_phone;
  @JsonKey(includeIfNull: false, name: "ci")
  late String customer_id;

  @JsonKey(name: "at", toJson: _ServerTimeStampFiller)
  int? accepted_timestamp;

  @JsonKey(includeIfNull: false, name: "nc")
  late int num_customers;

  SharedRideAcceptedCustomer();

  static List<dynamic>? List_ToJson(List<SharedRideAcceptedCustomer>? list) =>
      _ListToJson(list, _$SharedRideAcceptedCustomerToJson);

  static dynamic List_FromJson(dynamic list) =>
      _ListFromJson(list, _$SharedRideAcceptedCustomerFromJson);
}

@JsonSerializable()
class SharedRideSeparateDropoff {
  @JsonKey(includeIfNull: false, name: "cp")
  late String customer_phone;
  @JsonKey(includeIfNull: false, name: "ci")
  late String customer_id;

  @JsonKey(includeIfNull: false, name: "nc")
  late int num_customers;

  @JsonKey(includeIfNull: false, name: "dl")
  late List<double> dropoff_loc;

  static List<dynamic>? List_ToJson(List<SharedRideSeparateDropoff>? list) =>
      _ListToJson(list, _$SharedRideSeparateDropoffToJson);

  static dynamic List_FromJson(dynamic list) =>
      _ListFromJson(list, _$SharedRideSeparateDropoffFromJson);
}

@JsonSerializable()
class SharedRideDropoffPrice {
  @JsonKey(includeIfNull: false, name: "cp")
  late String customer_phone;
  @JsonKey(includeIfNull: false, name: "ci")
  late String customer_id;

  @JsonKey(includeIfNull: false, name: "nc")
  late int num_customers;

  @JsonKey(includeIfNull: false, name: "tk")
  late double travelled_km;
  @JsonKey(includeIfNull: false, name: "tt")
  late double travelled_time;

  @JsonKey(includeIfNull: false, name: "ep")
  late double each_price;
  @JsonKey(includeIfNull: false, name: "tp")
  late double total_price;

  @JsonKey(name: "dt", toJson: _ServerTimeStampFiller)
  int? dropoff_timestamp;
}
