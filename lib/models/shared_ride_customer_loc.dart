import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe/models/firebase_document.dart';

part 'shared_ride_customer_loc.g.dart';

class SharedRideCustomerLoc {
  static const String SHARED_RIDE_CUSTOMER_LOC_DATABASE_ROOT =
      "https://safetransports-et-1fb17.firebaseio.com/";

  static const KEY_HASH = "g";
  static const KEY_LOCATION = "l";
  static const KEY_LAT = "0";
  static const KEY_LNG = "1";
  static const KEY_DETAILS = "dt";
  static const KEY_PING = "p";

  static const FIELD_PING_TIMESTAMP = "ping_timestamp";

  String? customer_id;

  LatLng? current_loc;

  int? ping_timestamp;

  SharedRideCustomerLocDetails? customer_details;

  SharedRideCustomerLoc();

  factory SharedRideCustomerLoc.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map;

    return SharedRideCustomerLoc.fromMap(data, snapshot.key!);
  }

  factory SharedRideCustomerLoc.fromMap(Map data, String? customer_id) {
    var coords =
        data.containsKey(KEY_LOCATION) ? (data[KEY_LOCATION] as List) : null;
    var current_loc = coords != null ? LatLng(coords[0], coords[1]) : null;

    var ping = data.containsKey(KEY_PING) ? (data[KEY_PING] as Map) : Map();

    var details =
        data.containsKey(KEY_DETAILS) ? (data[KEY_DETAILS] as Map) : Map();

    return SharedRideCustomerLoc()
      ..customer_id = customer_id
      ..current_loc = current_loc
      ..ping_timestamp = ping[FIELD_PING_TIMESTAMP] ?? null
      ..customer_details = _$SharedRideCustomerLocDetailsFromJson(
          details.cast<String, dynamic>());
  }
}

@JsonSerializable()
class SharedRideCustomerLocDetails {
  static const FIELD_EVALUATING_RIDE_ID = "evaluating_ride_id";
  static const FIELD_IS_LOC_VALID = "is_loc_valid";
  static const FIELD_LAST_UPDATE_TIMESTAMP = "last_update_timestamp";

  String? evaluating_ride_id;
  bool? is_loc_valid;

  int? last_update_timestamp;

  SharedRideCustomerLocDetails();

  static String convertDetailFieldToDeepRideCustomerPath(String field) {
    return SharedRideCustomerLoc.KEY_DETAILS + "/" + field;
  }
}
