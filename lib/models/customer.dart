import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe/models/firebase_document.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allos this class to access private members in the generated files.
/// The value for this is .g.dart, where the star denotes the source file name.
part 'customer.g.dart';

@JsonSerializable()
class Customer extends FirebaseDocument {
  static const FIREBASE_STORAGE_PATH_CUSTOMER_FILES = 'customer_files';

  static const FIELD_PHONE_NUMBER = 'phone_number';
  static const FIELD_USER_NAME = 'user_name';
  static const FIELD_EMAIL = 'email';

  static const FIELD_HAS_DEV_ACCESS = 'has_dev_access';

  static const FIELD_DATE_CREATED = 'date_created';
  static const FIELD_DATE_LAST_LOGIN = 'date_last_login';

  static const FIELD_IS_ACTIVE = 'is_active';

  static const FIELD_IS_LOGGED_IN = 'is_logged_in';

  static const FIELD_DEVICE_REGISTRATION_TOKENS = 'device_registration_tokens';

  static const FIELD_LINK_IMG_PROFILE = 'link_img_profile';

  // END field name declarations

  bool? client_triggered_event;

  String? phone_number;
  String? user_name;
  String? email;

  bool? has_dev_access;
  bool? is_available_active; // for FTA purposes

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? date_created;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? date_last_login;

  @JsonKey(defaultValue: true)
  bool? is_active;
  @JsonKey(defaultValue: false)
  bool? is_logged_in;

  List<String>? device_registration_tokens;

  String? link_img_profile;

  bool? referral_activation_complete;
  String? referral_code;

  Customer();

  static String convertStoragePathToCustomerPath(
      String customerID, String fieldName, String fileExtension) {
    return '${FIREBASE_STORAGE_PATH_CUSTOMER_FILES}/${customerID}_${fieldName}${fileExtension}';
  }

  factory Customer.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Customer customer = Customer();

    var json = snapshot.data();
    if (json != null) {
      customer = _$CustomerFromJson(json);
      customer.documentID = snapshot.id;
    }

    return customer;
  }

  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  static String _generateParityBit(String ref_code) {
    String ALPHABETS = 'ABCDEFGHJKMNPQRTUVWXY346789';

    if (ref_code.length != 7) {
      return "-1";
    }

    int running_total = 0;
    for (int i = 0; i < ref_code.length; i++) {
      int digit = ALPHABETS.indexOf(ref_code[i]);

      running_total += digit * (pow(i + 10, 10) as int);
    }

    return ALPHABETS[running_total % ALPHABETS.length];
  }

  static bool isReferralCodeValid(String referral_code) {
    if (referral_code.length != 8)
      return false;
    referral_code = referral_code.toUpperCase();
    String parity_bit = referral_code[7];
    return parity_bit == _generateParityBit(referral_code.substring(0, 7));
  }
}
