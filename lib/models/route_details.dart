import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteDetails {
  late int distance_value;
  late int duration_value;
  late String distance_text;
  late String duration_text;

  late String encoded_points;

  late LatLng pickup_loc;

  late LatLng dropoff_loc;

  late double estimated_fare_price;

  RouteDetails();
}