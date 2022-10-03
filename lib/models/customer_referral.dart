import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

// This allows this class to access private members in the generated files.
// The value for this is .g.dart, where the star denotes the source file name.
part 'customer_referral.g.dart';

@JsonSerializable()
class ReferralRequest extends FirebaseDocument {
  static const FIELD_REFERRAL_PARENT_CODE = "referral_parent_code";
  static const FIELD_REFERRAL_CHILD_ID = "referral_child_id";

  static const FIELD_REFERRAL_STATUS_CODE = "referral_status_code";

  static const FIELD_DATE_REFERRAL = "date_referral";

  // END field name declarations
  static const int REFERRAL_STATUS_SUCCESSFUL = 1;
  static const int REFERRAL_STATUS_PARENT_DOES_NOT_EXIST = 2;
  static const int REFERRAL_STATUS_CHILD_DOES_NOT_EXIST = 3;
  static const int REFERRAL_STATUS_ALREADY_ACTIVATED = 4;
  static const int REFERRAL_STATUS_UNKNOWN_ERROR = 5;

  String? referral_parent_code;
  String? referral_child_id;

  int? referral_status_code;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? date_referral;

  ReferralRequest();

  factory ReferralRequest.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    ReferralRequest request = ReferralRequest();

    var json = snapshot.data();
    if (json != null) {
      request = _$ReferralRequestFromJson(json);
      request.documentID = snapshot.id;
    }

    return request;
  }

  Map<String, dynamic> toJson() => _$ReferralRequestToJson(this);
}
