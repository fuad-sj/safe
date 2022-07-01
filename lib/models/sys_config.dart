import 'package:safe/models/firebase_document.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sys_config.g.dart';

@JsonSerializable()
class SysConfig extends FirebaseDocument {
  static const FIELD_RATE_NORMAL_BASE_FARE = "rate_normal_base_fare";
  static const FIELD_RATE_NORMAL_PER_KM_CHARGE = "rate_normal_per_km_charge";
  static const FIELD_RATE_NORMAL_PER_MINUTE_CHARGE =
      "rate_normal_per_minute_charge";
  static const FIELD_SEARCH_RADIUS = "search_radius";

  // END field declarations

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? rate_normal_base_fare;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? rate_normal_per_km_charge;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? rate_normal_per_minute_charge;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? search_radius;

  SysConfig();


  factory SysConfig.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    SysConfig config = SysConfig();

    var json = snapshot.data();
    if (json != null) {
      config = _$SysConfigFromJson(json);
      config.documentID = snapshot.id;
    }

    return config;
  }

  Map<String, dynamic> toJson() => _$SysConfigToJson(this);
}
