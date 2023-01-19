import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'referral_transaction_log.g.dart';

@JsonSerializable()
class ReferralTransactionLog extends FirebaseDocument {
  static const TRANS_USER_ID = "user_id";
  static const TRANS_NAME = "user_name";
  static const TRANS_USER_PHONE = "user_phone";
  static const TRANS_TYPE = "trans_type";
  static const TRANS_AMOUNT = "trans_amount";
  static const TRANS_DATE_TIME_WINDOW = "date_time_window";
  static const TRANS_TIME_STAMP = "trans_timestamp";

  int? array_index; // not part of firebase data, only used for UI rendering

  String? user_id;
  String? user_phone;
  String? user_name;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? trans_amount;
  int? trans_type;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? trans_timestamp;

  // basically the timestamp of the date removed, only the date part
  int? date_time_window;

  ReferralTransactionLog();

  ReferralTransactionLog.withArgs(
      this.user_id,
      this.user_name,
      this.user_phone,
      this.trans_amount,
      this.trans_type,
      this.trans_timestamp,
      this.date_time_window);

  // quick way to clone
   ReferralTransactionLog.clone(ReferralTransactionLog other)
      : this.withArgs(
      other.user_id,
      other.user_name,
      other.user_phone,
      other.trans_amount,
      other.trans_type,
      other.trans_timestamp,
      other.date_time_window);

  factory ReferralTransactionLog.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    ReferralTransactionLog transactionLog = ReferralTransactionLog();

    var json = snapshot.data();
    if (json != null) {
      transactionLog = _$ReferralTransactionLogFromJson(json);
      transactionLog.documentID = snapshot.id;
    }

    return transactionLog;
  }

  Map<String, dynamic> toJson() => _$ReferralTransactionLogToJson(this);

}
