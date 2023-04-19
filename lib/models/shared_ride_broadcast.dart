import 'package:firebase_database/firebase_database.dart';

class SharedRideBroadcast {
  late String ride_id;

  late String place_name;
  late String place_id;

  late double est_price;

  late bool is_six_seater;

  late int timestamp;

  bool? is_cancelled;

  late String car_plate;
  late String car_details;

  int? seats_remaining;

  /**
   * This is a computed value, not stored ANYWHERE. but useful in comparing different broadcasts
   */
  double? distance_to_broadcast;

  SharedRideBroadcast();

  factory SharedRideBroadcast.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map;

    return SharedRideBroadcast.fromMap(data, snapshot.key!);
  }

  factory SharedRideBroadcast.fromMap(Map data, String ride_id) {
    return SharedRideBroadcast()
      ..ride_id = ride_id
      ..place_name = data["place_name"] ?? null
      ..place_id = data["place_id"] ?? null
      ..est_price = data["est_price"] + 0.0 ?? null
      ..is_six_seater = data["is_six_seater"] ?? null
      ..timestamp = data["timestamp"] ?? null
      ..is_cancelled = data["is_cancelled"] ?? null
      ..seats_remaining = data["seats_remaining"] ?? null
      ..car_plate = data["car_plate"] ?? null
      ..car_details = data["car_details"] ?? null;
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
