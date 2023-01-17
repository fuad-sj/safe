import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_version.g.dart';

@JsonSerializable()
class UpdateVersion extends FirebaseDocument {
  static const FIELD_VERSION_NUMBER = "version_number";
  static const FIELD_BUILD_NUMBER = "build_number";
  static const FIELD_IS_CUSTOMER_APP = "is_customer_app";
  static const FIELD_IS_FORCEFUL_UPDATE = "is_forceful_update";
  static const FIELD_DATE_VERSION_CREATED = "date_version_created";

  // END field name declarations

  String? version_number;
  int? build_number;
  bool? is_customer_app;
  bool? is_forceful_update;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? date_version_created;

  UpdateVersion();

  factory UpdateVersion.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    UpdateVersion version = UpdateVersion();

    var json = snapshot.data();
    if (json != null) {
      version = _$UpdateVersionFromJson(json);
      version.documentID = snapshot.id;
    }

    return version;
  }

  Map<String, dynamic> toJson() => _$UpdateVersionToJson(this);
}
