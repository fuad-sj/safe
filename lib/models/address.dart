import 'package:google_maps_flutter/google_maps_flutter.dart';

class Address {
  late String? placeFormattedAddress;
  late String placeName;
  late String? placeId;
  late LatLng location;

  Address({
    this.placeFormattedAddress,
    required this.placeName,
    this.placeId,
    required this.location,
  });
}
