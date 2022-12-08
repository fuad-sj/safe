// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

// This allows this class to access private members in the generated files.
// The value for this is .g.dart, where the star denotes the source file name.
part 'safe_otp_request.g.dart';

@JsonSerializable()
class SafeOTPRequest extends FirebaseDocument {
  static const FIELD_OTP_STATUS = "otp_status";
  static const FIELD_PHONE_NUMBER = "phone_number";
  static const FIELD_AUTH_PHONE_ID = "auth_phone_id";
  static const FIELD_OTP_CODE = "otp_code";

  // END: Field declarations

  static const int SAFE_OTP_STATUS_OTP_CREATED = 1;
  static const int SAFE_OTP_STATUS_OTP_SENT = 2;
  static const int SAFE_OTP_STATUS_OTP_SUCCESSFUL = 3;
  static const int SAFE_OTP_STATUS_OTP_EXPIRED = 4;

  // Error Codes
  static const int SAFE_OTP_ERROR_INVALID_STATE = 1;
  static const int SAFE_OTP_ERROR_WRONG_CODE = 2;

  int? otp_status;

  String? phone_number;

  String? auth_phone_id;

  String? otp_code; // the randomly generated OTP code

  SafeOTPRequest();

  factory SafeOTPRequest.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    SafeOTPRequest request = SafeOTPRequest();

    var json = snapshot.data();
    if (json != null) {
      request = _$SafeOTPRequestFromJson(json);
      request.documentID = snapshot.id;
    }

    return request;
  }

  Map<String, dynamic> toJson() => _$SafeOTPRequestToJson(this);
}
