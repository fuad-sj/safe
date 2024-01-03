import 'dart:collection';

import 'package:safe/models/firebase_document.dart';

class DriverStatus extends FirebaseDocument {
  static const TEST_DATABASE =
      "https://safetransports-et-b2d8f.firebaseio.com/";

  static const DRIVER_STATUS_FIREBASE_KEY = 'st';
  static const TRIP_STATUS_FIREBASE_KEY = 'ts';

  static const SHORTENED_FIELD_CAR_TYPE = 'ct';
  static const SHORTENED_FIELD_LAST_LOCATION_UPDATE = 'lu';
  static const SHORTENED_FIELD_VERSION = 'v';
  static const SHORTENED_FIELD_BUILD_NUMBER = 'bn';
  static const SHORTENED_FIELD_IS_DRIVER_ONLINE = 'do';
  static const SHORTENED_FIELD_IS_ALREADY_DISPATCHED = 'ad';
  static const SHORTENED_FIELD_CURRENT_REQUEST_ID = 'cr';
  static const SHORTENED_FIELD_CURRENT_TRIP_SAVE_TRIP_ID = 'ctsi';
  static const SHORTENED_FIELD_IS_SOS_DISPATCHED = 'sdi';
  static const SHORTENED_FIELD_IS_ACTIVE = 'apr';
  static const SHORTENED_FIELD_IS_DISPATCHED_SHARED_RIDE = 'dsr';
  static const SHORTENED_FIELD_CURRENT_BALANCE = 'cb';
  static const SHORTENED_FIELD_IS_TRIP_COMPLETED = 'itc';
  static const SHORTENED_FIELD_CURRENT_TRIP_ORDER_SOURCE = 'tso';
  static const SHORTENED_FIELD_CURRENT_TRIP_ORDER_STATUS = 'tst';
  static const SHORTENED_FIELD_OPTIONAL_UPDATE_AVAILABLE = "oua";
  static const SHORTENED_FIELD_FORCEFUL_UPDATE_AVAILABLE = "fua";
  static const SHORTENED_FIELD_DRIVER_FIELDS_UPDATED = 'dfu';

  static const SHORTENED_FIELD_PACKAGE_USAGE_COUNTER = "puc";
  static const SHORTENED_FIELD_PACKAGE_DAYS_USED = "pdu";
  static const SHORTENED_FIELD_PACKAGE_DAYS_EXTENDED_LEFT = "pdel";
  static const SHORTENED_FIELD_PACKAGE_LAST_TRIP_TIMESTAMP = "pltt";
  static const SHORTENED_FIELD_PACKAGE_LAST_TRIP_END_OF_DAY_TIMESTAMP =
      "pltedt";
  static const SHORTENED_FIELD_PACKAGE_PURCHASED_TIMESTAMP = "ppt";
  static const SHORTENED_FIELD_PACKAGE_DEADLINE_TIMESTAMP = "pdt";
  static const SHORTENED_FIELD_PACKAGE_EXTENDED_DEADLINE_TIMESTAMP = "pedt";
  static const SHORTENED_FIELD_PACKAGE_TYPE = "pt";
  static const SHORTENED_FIELD_PACKAGE_PURCHASE_ID = "ppi";

  int? car_type;

  int? last_location_update;

  String? version;
  int? build_number;

  bool? is_already_dispatched;
  bool? is_already_assigned;
  bool? is_active;
  bool? is_dispatched_shared_ride;

  bool? is_driver_online;

  bool? is_sos_dispatched;

  bool? is_trip_completed;

  int? current_trip_order_source;

  int? current_trip_order_status;

  bool? optional_update_available;
  bool? forceful_update_available;

  double? current_balance;
  String? current_trip_id;
  String? current_trip_save_trip_id;

  bool? driver_fields_updated;

  int? package_usage_counter;
  int? package_days_used;
  int? package_days_extended_left;
  int? package_last_trip_timestamp;
  int? package_last_trip_end_of_day_timestamp;
  int? package_purchased_timestamp;
  int? package_deadline_timestamp;
  int? package_extended_deadline_timestamp;
  int? package_type;
  String? package_purchase_id;

  /**
   * Below fields are only memory based fields, not stored in db
   */
  bool? package_has_expired;
  bool? package_is_extended;
  bool? package_is_last_day;

  /**
   * END: memory fields
   */

  DriverStatus();

  static String convertToDeepPath(String field,
      {bool isTripStatusField = false}) {
    String root_field = isTripStatusField
        ? TRIP_STATUS_FIREBASE_KEY
        : DRIVER_STATUS_FIREBASE_KEY;
    return root_field + '/' + field;
  }

  factory DriverStatus.fromRealtimeDbSnapshot(Object? obj) {
    DriverStatus status = DriverStatus();

    if (obj == null) return status;

    LinkedHashMap<Object?, Object?> fields = obj as LinkedHashMap;

    status
      ..last_location_update =
          fields[SHORTENED_FIELD_LAST_LOCATION_UPDATE] as int?
      ..version = fields[SHORTENED_FIELD_VERSION] as String?
      ..build_number = fields[SHORTENED_FIELD_BUILD_NUMBER] as int?
      ..is_already_dispatched =
          fields[SHORTENED_FIELD_IS_ALREADY_DISPATCHED] as bool?
      ..is_active = fields[SHORTENED_FIELD_IS_ACTIVE] as bool?
      ..is_driver_online = fields[SHORTENED_FIELD_IS_DRIVER_ONLINE] as bool?
      ..is_sos_dispatched = fields[SHORTENED_FIELD_IS_SOS_DISPATCHED] as bool?
      ..is_trip_completed = fields[SHORTENED_FIELD_IS_TRIP_COMPLETED] as bool?
      ..is_dispatched_shared_ride =
          fields[SHORTENED_FIELD_IS_DISPATCHED_SHARED_RIDE] as bool?
      ..current_trip_order_source =
          fields[SHORTENED_FIELD_CURRENT_TRIP_ORDER_SOURCE] as int?
      ..current_trip_order_status =
          fields[SHORTENED_FIELD_CURRENT_TRIP_ORDER_STATUS] as int?
      ..optional_update_available =
          fields[SHORTENED_FIELD_OPTIONAL_UPDATE_AVAILABLE] as bool?
      ..forceful_update_available =
          fields[SHORTENED_FIELD_FORCEFUL_UPDATE_AVAILABLE] as bool?
      ..current_trip_id = fields[SHORTENED_FIELD_CURRENT_REQUEST_ID] as String?
      ..current_trip_save_trip_id =
          fields[SHORTENED_FIELD_CURRENT_TRIP_SAVE_TRIP_ID] as String?
      ..driver_fields_updated =
          fields[SHORTENED_FIELD_DRIVER_FIELDS_UPDATED] as bool?
      ..package_usage_counter =
          fields[SHORTENED_FIELD_PACKAGE_USAGE_COUNTER] as int?
      ..package_days_used = fields[SHORTENED_FIELD_PACKAGE_DAYS_USED] as int?
      ..package_days_extended_left =
          fields[SHORTENED_FIELD_PACKAGE_DAYS_EXTENDED_LEFT] as int?
      ..package_last_trip_timestamp =
          fields[SHORTENED_FIELD_PACKAGE_LAST_TRIP_TIMESTAMP] as int?
      ..package_last_trip_end_of_day_timestamp =
          fields[SHORTENED_FIELD_PACKAGE_LAST_TRIP_END_OF_DAY_TIMESTAMP] as int?
      ..package_purchased_timestamp =
          fields[SHORTENED_FIELD_PACKAGE_PURCHASED_TIMESTAMP] as int?
      ..package_deadline_timestamp =
          fields[SHORTENED_FIELD_PACKAGE_DEADLINE_TIMESTAMP] as int?
      ..package_extended_deadline_timestamp =
          fields[SHORTENED_FIELD_PACKAGE_EXTENDED_DEADLINE_TIMESTAMP] as int?
      ..package_type = fields[SHORTENED_FIELD_PACKAGE_TYPE] as int?
      ..package_purchase_id =
          fields[SHORTENED_FIELD_PACKAGE_PURCHASE_ID] as String?;

    if (fields[SHORTENED_FIELD_CURRENT_BALANCE] != null) {
      dynamic balance = fields[SHORTENED_FIELD_CURRENT_BALANCE];
      status.current_balance = balance + 0.0;
    }

    return status;
  }
}

class CurrentTripStatus {
  static const CURRENT_TRIP_STATUS_FIREBASE_KEY = 'cts';
}
