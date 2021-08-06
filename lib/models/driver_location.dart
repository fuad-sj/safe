import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverLocation {
  late String driverID;
  late double latitude;
  late double longitude;

  double? orientation;

  DriverLocation({
    required this.driverID,
    required this.latitude,
    required this.longitude,
  });

  LatLng get getLocationLatLng => LatLng(latitude, longitude);

  static const _KEY_G = "g";
  static const _KEY_L = "l";
  factory DriverLocation.fromSnapshot(DataSnapshot snapshot) {
    String driverID = snapshot.key!;

    var data = snapshot.value as Map;
    var coords = data[_KEY_L] as List;
    double lat = coords[0];
    double lng = coords[1];

    return DriverLocation(
      driverID: driverID,
      latitude: lat,
      longitude: lng,
    );
  }
}
