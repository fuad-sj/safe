import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe/models/google_place_description.dart';
import 'package:safe/utils/http_util.dart';
import 'package:safe/models/address.dart';
import 'package:safe/models/route_details.dart';
import 'package:safe/constants.dart';
import 'package:safe/models/sys_config.dart';

class GoogleApiUtils {
  static const String REST_API_ROOT_PATH =
      "us-central1-safetransports-et.cloudfunctions.net";

  static String _getRandomInstanceEndPoint(SysConfig sysConfig) {
    Random random = new Random();
    int instId =
        random.nextInt(sysConfig.num_fun_https_cache_endpoints ?? 1) + 1;
    return "/CacheEndpoint$instId/api/v1/";
  }

  static String _getRandomInstanceEndPointFromIndex(int numEndpoints) {
    Random random = new Random();
    int instId = random.nextInt(numEndpoints) + 1;
    return "/CacheEndpoint$instId/api/v1/";
  }

  // Convert [lat,long] into an human readable address using google maps api
  static Future<Address> searchCoordinateLatLng(
      LatLng latLng, SysConfig sysConfig) async {
    Map<String, dynamic> params = {
      'lat': '${latLng.latitude}',
      'lng': '${latLng.longitude}',
    };

    var response = await HttpUtil.getHttpsRequest(REST_API_ROOT_PATH,
        _getRandomInstanceEndPoint(sysConfig) + 'geocode', params);

    String placeAddress = response['place'];

    return Address(
      location: LatLng(latLng.latitude, latLng.longitude),
      placeName: placeAddress,
    );
  }

  // Convert [lat,long] into an human readable address using google maps api
  static Future<Address> searchCoordinateAddress(Position position,
      // make the default value be 1
      {int numInstances = 1}) async {
    Map<String, dynamic> params = {
      'lat': '${position.latitude}',
      'lng': '${position.longitude}',
    };

    var response = await HttpUtil.getHttpsRequest(REST_API_ROOT_PATH,
        _getRandomInstanceEndPointFromIndex(numInstances) + 'geocode', params);

    String placeAddress = response['place'];

    return Address(
      location: LatLng(position.latitude, position.longitude),
      placeName: placeAddress,
    );
  }

  // Given a starting and ending point, generate the path and compute distance/time
  static Future<RouteDetails> getRouteDetailsFromStartToDestination(
      LatLng startPosition, LatLng destPosition, SysConfig sysConfig) async {
    Map<String, dynamic> params = {
      'start_lat': '${startPosition.latitude}',
      'start_lng': '${startPosition.longitude}',
      'dest_lat': '${destPosition.latitude}',
      'dest_lng': '${destPosition.longitude}',
    };

    var response = await HttpUtil.getHttpsRequest(REST_API_ROOT_PATH,
        _getRandomInstanceEndPoint(sysConfig) + 'directions', params);

    var dir_details = response['directions'];

    RouteDetails routeDetails = RouteDetails()
      ..distance_value = dir_details['path_length_meters']
      ..duration_value = dir_details['path_duration_seconds']
      ..distance_text = dir_details['path_length_str']
      ..duration_text = dir_details['path_duration_str']
      ..encoded_points = dir_details['encoded_points'];

    routeDetails.pickup_loc = startPosition;
    routeDetails.dropoff_loc = destPosition;

    routeDetails.estimated_fare_price =
        _calculateEstimatedFarePrice(routeDetails, sysConfig);

    return routeDetails;
  }

  static Future<Address> getPlaceAddressDetails(
      String placeId, String sessionId, SysConfig sysConfig) async {
    Map<String, dynamic> params = {
      'place_id': '${placeId}',
      'session_id': '${sessionId}',
    };

    var response = await HttpUtil.getHttpsRequest(REST_API_ROOT_PATH,
        _getRandomInstanceEndPoint(sysConfig) + 'place_detail', params);

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
      String placeName, String sessionId, SysConfig sysConfig) async {
    Map<String, dynamic> params = {
      'search': '${placeName}',
      'session_id': '${sessionId}',
    };

    var response = await HttpUtil.getHttpsRequest(REST_API_ROOT_PATH,
        _getRandomInstanceEndPoint(sysConfig) + 'auto_complete', params);

    var predictions = response['matches'];

    return (predictions as List)
        .map((json) => GooglePlaceDescription.fromJson(json))
        .toList();
  }

  static double _calculateEstimatedFarePrice(
      RouteDetails directionDetails, SysConfig? sysConfig) {
    double base_fare =
        (sysConfig == null) ? 85.0 : sysConfig.rate_normal_base_fare!;
    double per_km =
        (sysConfig == null) ? 10.0 : sysConfig.rate_normal_fair_per_km_charge!;
    double per_minute = (sysConfig == null)
        ? 1.0
        : sysConfig.rate_normal_fair_per_minute_charge!;

    double timeTraveledFare =
        ((directionDetails.duration_value + 0.0) / 60.0) * per_minute;
    double distanceTraveledFare =
        ((directionDetails.distance_value + 0.0) / 1000) * per_km;
    double totalPrice =
        timeTraveledFare * 0.5 + distanceTraveledFare + base_fare;

    return totalPrice;
  }
}
