import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

// This allows this class to access private members in the generated files.
// The value for this is .g.dart, where the star denotes the source file name.
part 'ride_request.g.dart';

@JsonSerializable()
class RideRequest extends FirebaseDocument {
  static const FIELD_CLIENT_TRIGGERED_EVENT = 'client_triggered_event';

  static const FIELD_RIDE_STATUS = 'ride_status';

  static const FIELD_CANCEL_SOURCE = 'cancel_source';
  static const FIELD_CANCEL_SOURCE_TRIGGER_SOURCE_ID =
      'cancel_source_trigger_source_id';
  static const FIELD_CANCEL_CODE = 'cancel_code';
  static const FIELD_CANCEL_REASON = 'cancel_reason';

  static const FIELD_CUSTOMER_ID = 'customer_id';
  static const FIELD_CUSTOMER_NAME = 'customer_name';
  static const FIELD_CUSTOMER_PHONE = 'customer_phone';
  static const FIELD_CUSTOMER_DEVICE_TOKEN = 'customer_device_token';

  static const FIELD_PICKUP_LOCATION = 'pickup_location';
  static const FIELD_PICKUP_ADDRESS_NAME = 'pickup_address_name';

  static const FIELD_DROPOFF_LOCATION = 'dropoff_location';
  static const FIELD_DROPOFF_ADDRESS_NAME = 'dropoff_address_name';

  static const FIELD_DATE_RIDE_CREATED = 'date_ride_created';

  static const FIELD_IS_SCHEDULED = 'is_scheduled';
  static const FIELD_SCHEDULED_AFTER_SECONDS = 'scheduled_after_seconds';

  static const FIELD_DRIVER_ID = 'driver_id';
  static const FIELD_DRIVER_NAME = 'driver_name';
  static const FIELD_DRIVER_PHONE = 'driver_phone';
  static const FIELD_DRIVER_DEVICE_TOKEN = 'driver_device_token';

  static const FIELD_DRIVER_TO_PICKUP_DISTANCE_METERS =
      'driver_to_pickup_distance_meters';
  static const FIELD_DRIVER_TO_PICKUP_DISTANCE_STR =
      'driver_to_pickup_distance_str';

  static const FIELD_DRIVER_TO_PICKUP_DURATION_SECONDS =
      'driver_to_pickup_duration_seconds';
  static const FIELD_DRIVER_TO_PICKUP_DURATION_STR =
      'driver_to_pickup_duration_str';
  static const FIELD_DRIVER_TO_PICKUP_ENCODED_POINTS =
      'driver_to_pickup_encoded_points';

  static const FIELD_ESTIMATED_FARE = 'estimated_fare';

  static const FIELD_ACTUAL_PICKUP_LOCATION = 'actual_pickup_location';
  static const FIELD_ACTUAL_DROPOFF_LOCATION = 'actual_dropoff_location';

  static const FIELD_ACTUAL_PICKUP_TO_INITIAL_DROPOFF_ENCODED_POINTS =
      'actual_pickup_to_initial_dropoff_encoded_points';

  static const FIELD_CAR_MODEL = 'car_model';
  static const FIELD_CAR_COLOR = 'car_color';
  static const FIELD_CAR_NUMBER = 'car_number';

  // used to specify which driver generated the current cloud functions trigger
  static const FIELD_TRIGGER_SOURCE_DRIVER_ID = 'trigger_source_driver_id';

  static const FIELD_ACTUAL_BASE_FARE = "base_fare";
  static const FIELD_ACTUAL_TRIP_FARE = "actual_trip_fare";
  static const FIELD_ACTUAL_TRIP_MINUTES = "actual_trip_minutes";
  static const FIELD_ACTUAL_TRIP_KILOMETERS = "actual_trip_kilometers";

  // END field name declarations

  static const int STATUS_DRIVER_NOT_FOUND = -5;
  static const int STATUS_DELETED = -4;
  static const int STATUS_TIMEOUT = -3;
  static const int STATUS_CANCELLED = -2;

  static const int STATUS_PLACED = 1;
  static const int STATUS_PENDING_DRIVER = 2;

  static const int STATUS_DRIVER_PICKED = 3;
  static const int STATUS_DRIVER_REJECTED = 4;
  static const int STATUS_DRIVER_ACCEPTED = 5;
  static const int STATUS_DRIVER_CONFIRMED = 6;
  static const int STATUS_DRIVER_ARRIVED_AT_PICKUP = 7;

  static const int STATUS_TRIP_STARTED = 8;
  static const int STATUS_DRIVER_ARRIVED_AT_DROPOFF = 9;
  static const int STATUS_TRIP_COMPLETED = 10;

  static const int CANCEL_SOURCE_NONE = 0;
  static const int CANCEL_SOURCE_CUSTOMER = 1;
  static const int CANCEL_SOURCE_DRIVER = 2;
  static const int CANCEL_SOURCE_DISPATCHER = 3;

  static bool isRideRequestCancelled(int rideStatus) {
    return rideStatus < 0;
  }

  static bool hasDriverBeenPicked(int rideStatus) {
    return rideStatus >= STATUS_DRIVER_PICKED;
  }

  bool? client_triggered_event;

  late int ride_status;

  int? cancel_source;
  String? cancel_source_trigger_source_id;
  int? cancel_code;
  String? cancel_reason;

  String? customer_id;
  late String customer_name;
  late String customer_phone;
  String? customer_device_token;

  @JsonKey(
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? pickup_location;
  late String pickup_address_name;

  @JsonKey(
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? dropoff_location;
  late String dropoff_address_name;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? date_ride_created;

  bool? is_scheduled;
  int? scheduled_after_seconds;

  String? driver_id;
  String? driver_name;
  String? driver_phone;
  String? driver_device_token;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? driver_to_pickup_distance_meters;
  String? driver_to_pickup_distance_str;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? driver_to_pickup_duration_seconds;
  String? driver_to_pickup_duration_str;
  String? driver_to_pickup_encoded_points;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? estimated_fare;

  @JsonKey(
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? actual_pickup_location;
  @JsonKey(
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? actual_dropoff_location;

  String? actual_pickup_to_initial_dropoff_encoded_points;

  String? car_model;
  String? car_color;
  String? car_number;

  String? trigger_source_driver_id;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? base_fare;
  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? actual_trip_fare;
  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? actual_trip_minutes;
  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? actual_trip_kilometers;

  RideRequest();

  factory RideRequest.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    RideRequest request = RideRequest();

    var json = snapshot.data();
    if (json != null) {
      request = _$RideRequestFromJson(json);
      request.documentID = snapshot.id;
    }

    return request;
  }

  Map<String, dynamic> toJson() => _$RideRequestToJson(this);
}
