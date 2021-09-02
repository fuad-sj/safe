import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/utils/http_util.dart';
import 'package:safe/models/address.dart';
import 'package:safe/models/route_details.dart';
import 'package:safe/constants.dart';

class GoogleApiUtils {
  static const String REST_API_ROOT_PATH =
      "us-central1-waliif-ride-adea0.cloudfunctions.net";

  // Convert [lat,long] into an human readable address using google maps api
  static Future<Address> searchCoordinateLatLng(LatLng latLng) async {
    Map<String, dynamic> params = {
      'lat': '${latLng.latitude}',
      'lng': '${latLng.longitude}',
    };

    var response = await HttpUtil.getHttpsRequest(
        REST_API_ROOT_PATH, '/RESTApis/api/v1/geocode', params);

    String placeAddress = response['place'];

    return Address(
      location: LatLng(latLng.latitude, latLng.longitude),
      placeName: placeAddress,
    );
  }

  // Convert [lat,long] into an human readable address using google maps api
  static Future<Address> searchCoordinateAddress(Position position) async {
    Map<String, dynamic> params = {
      'lat': '${position.latitude}',
      'lng': '${position.longitude}',
    };

    var response = await HttpUtil.getHttpsRequest(
        REST_API_ROOT_PATH, '/RESTApis/api/v1/geocode', params);

    String placeAddress = response['place'];

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

  static Future<Address> getPlaceAddressDetails(
      String placeId, String sessionId) async {
    Map<String, dynamic> params = {
      'place_id': '${placeId}',
      'session_id': '${sessionId}',
    };

    var response = await HttpUtil.getHttpsRequest(
        REST_API_ROOT_PATH, '/RESTApis/api/v1/place_detail', params);

    var detail = response['detail'];

    return Address(
      placeId: placeId,
      placeName: detail['place_name'],
      location: LatLng(
        detail['latitude'],
        detail['longitude'],
      ),
    );
  }

  static Future<List<GooglePlaceDescription>?> autoCompletePlaceName(
      String placeName, String sessionId) async {
    Map<String, dynamic> params = {
      'search': '${placeName}',
      'session_id': '${sessionId}',
    };

    var response = await HttpUtil.getHttpsRequest(
        REST_API_ROOT_PATH, '/RESTApis/api/v1/auto_complete', params);

    var predictions = response['matches'];

    return (predictions as List)
        .map((json) => GooglePlaceDescription.fromJson(json))
        .toList();
  }

  static double _calculateEstimatedFarePrice(RouteDetails directionDetails) {
    double timeTraveledFare =
        ((directionDetails.durationValue + 0.0) / 60.0) * 1.0;
    double distanceTraveledFare =
        ((directionDetails.distanceValue + 0.0) / 1000) * 10.0;
    double totalPrice = timeTraveledFare + distanceTraveledFare + 60;

    return totalPrice;
  }
}
