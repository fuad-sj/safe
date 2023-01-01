import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

part 'referral_payment_request.g.dart';

@JsonSerializable()
class ReferralPaymentRequest extends FirebaseDocument {
  static const FIELD_CLIENT_TRIGGERED_EVENT = "client_triggered_event";
  static const FIELD_REQUEST_STATUS = "request_status";
  static const FIELD_ERROR_CODE = "error_code";
  static const FIELD_ERROR_MSG = "error_msg";
  static const FIELD_REQUEST_TYPE = "request_type";
  static const FIELD_PAYMENT_AMOUNT = "payment_amount";
  static const FIELD_REQUESTER_ID = "requester_id";
  static const FIELD_REQUESTER_NAME = "requester_name";
  static const FIELD_REQUESTER_PHONE = "requester_phone";
  static const FIELD_SEND_TO_ID = "send_to_id";
  static const FIELD_SEND_TO_NAME = "send_to_name";
  static const FIELD_SEND_TO_PHONE = "send_to_phone";
  static const FIELD_REF_TRANSACTION_ID = "ref_transaction_id";
  static const FIELD_REQUESTED_TIME = "requested_time";

  // END field name declarations

  static const REQUEST_STATUS_CREATED = 1;
  static const REQUEST_STATUS_ACCOUNT_CREDITED = 2;
  static const REQUEST_STATUS_QUEUED_FOR_PROCESSING = 3;
  static const REQUEST_STATUS_PROCESSED = 4;
  static const REQUEST_STATUS_COMPLETED = 5;
  static const REQUEST_STATUS_ROLLBACK_PAYMENT = 6;
  static const REQUEST_STATUS_ERROR = -1;

  static const ERROR_REQUEST_GENERAL_ERROR = -1;
  static const ERROR_REQUEST_INSUFFICIENT_BALANCE = 1;
  static const ERROR_REQUEST_DUPLICATE_REQUEST = 2;
  static const ERROR_REQUEST_PAYMENT_ROLLBACK = 3;

  static const PAYMENT_REQUEST_TYPE_CASH_OUT = 1;
  static const PAYMENT_REQUEST_TYPE_SEND_TO = 2;

  bool? client_triggered_event;

  int? request_status;
  int? error_code;
  String? error_msg;

  int? request_type;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? payment_amount;

  String? requester_id;
  String? requester_name;
  String? requester_phone;

  String? send_to_id;
  String? send_to_name;
  String? send_to_phone;

  // reference id to be used to validate this transactions from Tele/Bank
  String? ref_transaction_id;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? requested_time;
}
