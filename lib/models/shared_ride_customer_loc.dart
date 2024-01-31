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
  static const KEY_REQUEST_DRIVERS = "rd";

  static const FIELD_PING_TIMESTAMP = "pt";

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
  static const F_EVALUATING_RIDE_ID = "eri";
  @JsonKey(includeIfNull: false, name: F_EVALUATING_RIDE_ID)
  String? evaluating_ride_id;

  static const F_EVALUATING_DEST_PLACE_ID = "edpi";
  @JsonKey(includeIfNull: false, name: F_EVALUATING_DEST_PLACE_ID)
  String? evaluating_dest_place_id;

  static const F_IS_LOC_VALID = "ilv";
  @JsonKey(includeIfNull: false, name: F_IS_LOC_VALID)
  bool? is_loc_valid;

  static const F_COMPASS_ORIENTATION = "co";
  @JsonKey(includeIfNull: false, name: F_COMPASS_ORIENTATION)
  double? compass_orientation;

  static const F_LAST_UPDATE_TIMESTAMP = "lut";
  @JsonKey(includeIfNull: false, name: F_LAST_UPDATE_TIMESTAMP)
  int? last_update_timestamp;

  SharedRideCustomerLocDetails();

  static String convertDetailFieldToDeepRideCustomerPath(String field) {
    return SharedRideCustomerLoc.KEY_DETAILS + "/" + field;
  }
}

@JsonSerializable()
class SharedRideCustomerRequestNearbyDriver {
  static const F_REQUEST_LOC = "rloc";
  @JsonKey(
      includeIfNull: false,
      name: F_REQUEST_LOC,
      fromJson: FirebaseDocument.LatLngFromJson,
      toJson: FirebaseDocument.LatLngToJson)
  LatLng? request_loc;

  static const F_CUSTOMER_DEVICE_TOKEN = "cdt";
  @JsonKey(includeIfNull: false, name: F_CUSTOMER_DEVICE_TOKEN)
  String? customer_device_token;

  static const F_DESTINATION_PLACE_NAME = "dpn";
  @JsonKey(includeIfNull: false, name: F_DESTINATION_PLACE_NAME)
  String? destination_place_name;

  static const F_DESTINATION_PLACE_ID = "dpi";
  @JsonKey(includeIfNull: false, name: F_DESTINATION_PLACE_ID)
  String? destination_place_id;

  static const F_LAST_UPDATE_TIMESTAMP = "lut";
  @JsonKey(includeIfNull: false, name: F_LAST_UPDATE_TIMESTAMP)
  int? last_update_timestamp;

  static const F_IS_SCHEDULED_REQUEST = "isr";
  @JsonKey(includeIfNull: false, name: F_IS_SCHEDULED_REQUEST)
  bool? is_scheduled_request;

  static const F_SCHEDULED_AFTER_MINUTES = "sam";
  @JsonKey(includeIfNull: false, name: F_SCHEDULED_AFTER_MINUTES)
  int? scheduled_after_minutes;
}
