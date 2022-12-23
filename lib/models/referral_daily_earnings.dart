import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'referral_daily_earnings.g.dart';

@JsonSerializable()
class ReferralDailyEarnings extends FirebaseDocument {
  static const FIELD_USER_ID = "user_id";
  static const FIELD_USER_NAME = "user_name";
  static const FIELD_USER_PHONE = "user_phone";
  static const FIELD_EARNING_AMOUNT = "earning_amount";
  static const FIELD_REFERENCE_COUNTER = "reference_counter";
  static const FIELD_LAST_UPDATE = "last_update";
  static const FIELD_TIME_WINDOW = "time_window";

  int? array_index; // not part of firebase data, only used for UI rendering

  String? user_id;
  String? user_name;
  String? user_phone;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? earning_amount;
  int? reference_counter;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? last_update;

  // basically the timestamp of the date removed, only the date part
  int? time_window;

  ReferralDailyEarnings();

  factory ReferralDailyEarnings.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    ReferralDailyEarnings earnings = ReferralDailyEarnings();

    var json = snapshot.data();
    if (json != null) {
      earnings = _$ReferralDailyEarningsFromJson(json);
      earnings.documentID = snapshot.id;
    }

    return earnings;
  }

  Map<String, dynamic> toJson() => _$ReferralDailyEarningsToJson(this);
}
