import 'package:firebase_database/firebase_database.dart';

class SharedRideDestLocation {
  late String place_id;
  late String name;
  late double lat;
  late double lng;

  SharedRideDestLocation();

  factory SharedRideDestLocation.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map;

    return SharedRideDestLocation.fromMap(data, snapshot.key!);
  }

  factory SharedRideDestLocation.fromMap(Map data, String place_id) {
    return SharedRideDestLocation()
      ..place_id = place_id
      ..name = data["name"]
      ..lat = data["lat"] + 0.0
      ..lng = data["lng"] + 0.0;
  }
}
