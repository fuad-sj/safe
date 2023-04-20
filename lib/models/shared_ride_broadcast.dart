import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SharedRideBroadcast {
  late String ride_id;

  late String place_name;
  late String place_id;
  late LatLng place_loc;
  late LatLng initial_loc;

  late int created_timestamp;
  int? ping_timestamp;
  int? trip_started_timestamp;

  String? driver_name;
  String? driver_phone;
  String? car_plate;
  String? car_details;
  bool? is_six_seater;

  double? est_price;

  bool? is_setup_done;
  bool? is_trip_cancelled;
  bool? is_stale_order;
  bool? is_fully_booked;
  bool? is_trip_started;
  bool? is_trip_completed;

  bool? is_forcefully_filled;
  int? num_forceful_filled;

  int? seats_remaining;

  /**
   * This is a computed value, not stored ANYWHERE. but useful in comparing different broadcasts
   */
  double? distance_to_broadcast;

  bool isValidOrderToConsider() {
    if ((is_setup_done ?? false) != true) {
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
      ..ride_id = ride_id
      ..place_name = data["place_name"]
      ..place_id = data["place_id"]
      ..place_loc = LatLng.fromJson(data["place_loc"])!
      ..initial_loc = LatLng.fromJson(data["initial_loc"])!
      ..created_timestamp = data["created_timestamp"] ?? null
      ..ping_timestamp = data["ping_timestamp"] ?? null
      ..trip_started_timestamp = data["trip_started_timestamp"] ?? null
      ..driver_name = data["driver_name"] ?? null
      ..driver_phone = data["driver_phone"] ?? null
      ..car_plate = data["car_plate"] ?? null
      ..car_details = data["car_details"] ?? null
      ..is_six_seater = data["is_six_seater"] ?? null
      ..est_price = data["est_price"] ?? null
      ..is_setup_done = data["is_setup_done"] ?? null
      ..is_trip_cancelled = data["is_trip_cancelled"] ?? null
      ..is_stale_order = data["is_stale_order"] ?? null
      ..is_fully_booked = data["is_fully_booked"] ?? null
      ..is_trip_started = data["is_trip_started"] ?? null
      ..is_trip_completed = data["is_trip_completed"] ?? null
      ..is_forcefully_filled = data["is_forcefully_filled"] ?? null
      ..num_forceful_filled = data["num_forceful_filled"] ?? null
      ..seats_remaining = data["seats_remaining"] ?? null;
  }
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
