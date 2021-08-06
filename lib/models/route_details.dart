import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDetails {
  late int distanceValue;
  late int durationValue;
  late String distanceText;
  late String durationText;

  late String encodedPoints;

  late LatLng pickUpLoc;
  late LatLng dropOffLoc;

  late double estimatedFarePrice;

  RouteDetails({
    required this.distanceValue,
    required this.durationValue,
    required this.distanceText,
    required this.durationText,
    required this.encodedPoints,
  });
}
