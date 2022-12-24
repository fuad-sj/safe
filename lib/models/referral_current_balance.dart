import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'referral_current_balance.g.dart';

@JsonSerializable()
class ReferralCurrentBalance extends FirebaseDocument {
  String? user_id;
  String? user_name;
  String? user_phone;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? current_balance;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? last_update_timestamp;

  int? last_update_trans_type;

  ReferralCurrentBalance();

  factory ReferralCurrentBalance.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    ReferralCurrentBalance earnings = ReferralCurrentBalance();

    var json = snapshot.data();
    if (json != null) {
      earnings = _$ReferralCurrentBalanceFromJson(json);
      earnings.documentID = snapshot.id;
    }

    return earnings;
  }

  Map<String, dynamic> toJson() => _$ReferralCurrentBalanceToJson(this);
}
