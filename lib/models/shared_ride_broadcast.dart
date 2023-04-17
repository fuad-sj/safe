import 'package:firebase_database/firebase_database.dart';

class SharedRideBroadcast {
  String? ride_id;

  String? dest_name;
  String? dest_id;
  double? est_price;

  int? timestamp;

  bool? is_cancelled;

  int? seats_remaining;

  String? car_plate;
  String? car_details;

  /**
   * This is a computed value, not stored ANYWHERE. but useful in comparing different broadcasts
   */
  double? distance_to_broadcast;

  SharedRideBroadcast();

  factory SharedRideBroadcast.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map;

    return SharedRideBroadcast()
      ..ride_id = snapshot.key!
      ..dest_name = data["dest_name"] ?? null
      ..dest_id = data["dest_id"] ?? null
      ..est_price = data["est_price"] + 0.0 ?? null
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
  double est_price;

  Set<String> place_rides;

  String? selected_ride_id;
  int? selected_ride_timestamp;
  double? selected_ride_distance;

  SharedRidePlaceAggregate({
    required this.place_id,
    required this.place_name,
    required this.est_price,
    required this.place_rides,
  });
}
