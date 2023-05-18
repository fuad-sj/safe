import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe/models/firebase_document.dart';

part 'token_version_and_update_info.g.dart';

@JsonSerializable()
class TokenVersionAndUpdateInfo {
  static final String DATABASE_ROOT = "https://safetransports-et-cb6a3.firebaseio.com/";

  @JsonKey(includeIfNull: false, name: "dt")
  String? device_token;

  @JsonKey(includeIfNull: false, name: "vn")
  String? version_number;
  @JsonKey(includeIfNull: false, name: "bn")
  int? build_number;

  @JsonKey(name: "lu", toJson: FirebaseDocument.EmptyServerTimeStampFiller)
  int? last_update_timestamp;

  /// the fields below are usually read, not written to
  @JsonKey(includeIfNull: false, name: "cte")
  bool? client_triggered_event;

  @JsonKey(includeIfNull: false, name: "oua")
  bool? optional_update_available;

  @JsonKey(includeIfNull: false, name: "fua")
  bool? forceful_update_available;

  @JsonKey(includeIfNull: false, name: "ira")
  bool? is_referral_active;

  TokenVersionAndUpdateInfo();

  factory TokenVersionAndUpdateInfo.fromJson(Map json) =>
      _$TokenVersionAndUpdateInfoFromJson(json.cast<String, dynamic>());

  Map<String, dynamic> toJson() => _$TokenVersionAndUpdateInfoToJson(this);
}
