import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/utils/http_util.dart';
import 'package:safe/models/address.dart';
import 'package:safe/models/route_details.dart';
import 'package:safe/constants.dart';

class GoogleApiUtils {
  // Convert [lat,long] into an human readable address using google maps api
  static Future<Address?> searchCoordinateLatLng(LatLng latLng) async {
    Map<String, dynamic> params = {
      'latlng': '${latLng.latitude},${latLng.longitude}',
      'key': '$GoogleMapKey',
    };

    var response = await HttpUtil.getHttpsRequest(
        'maps.googleapis.com', "/maps/api/geocode/json", params);

    String st1 = response['results'][0]['address_components'][1]["long_name"];
    String st2 = response['results'][0]['address_components'][2]["long_name"];
    String st3 = response['results'][0]['address_components'][3]["long_name"];

    String placeAddress = '$st1, $st2, $st3';

    return Address(
      location: LatLng(latLng.latitude, latLng.longitude),
      placeName: placeAddress,
    );
  }

  // Convert [lat,long] into an human readable address using google maps api
  static Future<Address?> searchCoordinateAddress(Position position) async {
    Map<String, dynamic> params = {
      'latlng': '${position.latitude},${position.longitude}',
      'key': '$GoogleMapKey',
    };

    var response = await HttpUtil.getHttpsRequest(
        'maps.googleapis.com', "/maps/api/geocode/json", params);

    String st1 = response['results'][0]['address_components'][1]["long_name"];
    String st2 = response['results'][0]['address_components'][2]["long_name"];
    String st3 = response['results'][0]['address_components'][3]["long_name"];

    String placeAddress = '$st1, $st2, $st3';

    return Address(
      location: LatLng(position.latitude, position.longitude),
      placeName: placeAddress,
    );
  }

  // Given a starting and ending point, generate the path and compute distance/time
  static Future<RouteDetails> getRouteDetailsFromStartToDestination(
      LatLng startPosition, LatLng destPosition) async {
    Map<String, dynamic> params = {
      'mode': 'driving',
      'transit_routing_preference': 'less_driving',
      'origin': '${startPosition.latitude},${startPosition.longitude}',
      'destination': '${destPosition.latitude},${destPosition.longitude}',
      'key': '$GoogleMapKey',
    };

    var response = await HttpUtil.getHttpsRequest(
        'maps.googleapis.com', "/maps/api/directions/json", params);

    RouteDetails routeDetails = RouteDetails(
      distanceValue: response['routes'][0]['legs'][0]['distance']['value'],
      durationValue: response['routes'][0]['legs'][0]['duration']['value'],
      distanceText: response['routes'][0]['legs'][0]['distance']['text'],
      durationText: response['routes'][0]['legs'][0]['duration']['text'],
      encodedPoints: response['routes'][0]['overview_polyline']['points'],
    );

    routeDetails.pickUpLoc = startPosition;
    routeDetails.dropOffLoc = destPosition;

    routeDetails.estimatedFarePrice =
        _calculateEstimatedFarePrice(routeDetails);

    return routeDetails;
  }

  static Future<Address?> getPlaceAddressDetails(String placeId) async {
    Map<String, dynamic> params = {
      'place_id': '$placeId',
      'key': '$GoogleMapKey',
    };

    try {
      var response = await HttpUtil.getHttpsRequest(
          'maps.googleapis.com', '/maps/api/place/details/json', params);

      if (response['status'] != 'OK') return null;

      var result = response['result'];

      Address address = Address(
        placeId: placeId,
        placeName: result['name'],
        location: LatLng(
          result['geometry']['location']['lat'],
          result['geometry']['location']['lng'],
        ),
      );

      return address;
    } catch (err) {}

    return null;
  }

  static Future<List<GooglePlaceDescription>?> searchForBestMatchingPlace(
      String placeName) async {
    Map<String, dynamic> params = {
      'input': '$placeName',
      'key': '$GoogleMapKey',
      'sessiontoken': '1234567890',
      'components': 'country:et'
    };

    try {
      var response = await HttpUtil.getHttpsRequest(
          'maps.googleapis.com', '/maps/api/place/autocomplete/json', params);

      if (response['status'] != 'OK') return null;

      var predictions = response['predictions'];

      return (predictions as List)
          .map((json) => GooglePlaceDescription.fromJson(json))
          .toList();
    } catch (err) {}

    return null;
  }

  static double _calculateEstimatedFarePrice(RouteDetails directionDetails) {
    double timeTraveledFare =
        ((directionDetails.durationValue + 0.0) / 60.0) * 0.2;
    double distanceTraveledFare =
        ((directionDetails.distanceValue + 0.0) / 1000) * 0.2;
    double totalPrice = timeTraveledFare + distanceTraveledFare;

    totalPrice *= 43;
    return totalPrice;
  }
}