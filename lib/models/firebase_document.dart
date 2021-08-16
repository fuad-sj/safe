import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
abstract class FirebaseDocument {
  // this field doesn't actually exist in the db, so don't serialize it
  @JsonKey(ignore: true)
  String? documentID;

  bool documentExists() => documentID != null;

  static DateTime? DateTimeFromJson(Object? json) {
    if (json == null) return null;

    return (json as Timestamp).toDate();
  }

  static DateTime? DateTimeToJson(dynamic json) {
    return json;
  }

  static double? DoubleFromJson(dynamic number) {
    if (number == null) return null;
    return number + 0.0;
  }

  static LatLng? LatLngFromJson(dynamic json) {
    return LatLng.fromJson(json);
  }

  static dynamic LatLngToJson(LatLng? latLng) {
    if (latLng == null) return null;
    return [latLng.latitude, latLng.longitude];
  }

  static dynamic PositionToJson(Position? position) {
    if (position == null) return null;
    return [position.latitude, position.longitude];
  }
}