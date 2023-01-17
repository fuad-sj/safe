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
  static const FIELD_USER_LAST_NAME = 'last_user_name';
  static const FIELD_GENDER = 'gender';
  static const FIELD_EMAIL = 'email';

  static const FIELD_VERSION_NUMBER = 'version_number';
  static const FIELD_VERSION_BUILD_NUMBER = 'version_build_number';

  static const FIELD_NUM_DIRECT_CHILDREN = 'num_direct_children';
  static const FIELD_NUM_TOTAL_CHILDREN = 'num_total_children';

  static const FIELD_LAST_READ_CURRENT_BALANCE = "last_read_current_balance";
  static const FIELD_LAST_READ_TOTAL_CHILDREN = "last_read_total_children";

  static const FIELD_NUM_CHILDREN_UNDER_NODE = 'num_children_under_node';

  static const FIELD_DATETIME_VERSION_DATE = 'datetime_version_date';

  static const FIELD_LAST_CHECKED_VERSION_NUMBER =
      'last_checked_version_number';
  static const FIELD_LAST_CHECKED_VERSION_DATETIME =
      'last_checked_version_datetime';
  static const FIELD_LAST_CHECKED_BUILD_NUMBER = 'last_checked_build_number';

  static const FIELD_HAS_DEV_ACCESS = 'has_dev_access';

  static const FIELD_DATE_CREATED = 'date_created';
  static const FIELD_DATE_LAST_LOGIN = 'date_last_login';

  static const FIELD_IS_ACTIVE = 'is_active';

  static const FIELD_IS_LOGGED_IN = 'is_logged_in';

  static const FIELD_DEVICE_REGISTRATION_TOKENS = 'device_registration_tokens';

  static const FIELD_LINK_IMG_PROFILE = 'link_img_profile';

  // END field name declarations

  static const int GENDER_FEMALE = 1;
  static const int GENDER_MALE = 2;

  bool? client_triggered_event;

  String? phone_number;
  String? user_name;
  String? last_user_name;
  String? referral_code;
  int? gender;
  String? email;

  String? version_number;
  int? version_build_number;

  int? num_direct_children;
  int? num_total_children;

  @JsonKey(fromJson: FirebaseDocument.DoubleFromJson)
  double? last_read_current_balance;
  int? last_read_total_children;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? datetime_version_date;

  String? last_checked_version_number;
  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? last_checked_version_datetime;
  int? last_checked_build_number;

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

  Customer();

  static String convertStoragePathToCustomerPath(
      String customerID, String fieldName, String fileExtension) {
    return '${FIREBASE_STORAGE_PATH_CUSTOMER_FILES}/${customerID}_${fieldName}${fileExtension}';
  }

  bool accountFullyCreated() {
    return phone_number != null &&
        phone_number!.trim() != "" &&
        user_name != null;
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

  static int _getPrimeForIndex(int index) {
    if (index == 0) {
      return 1;
    }
    var primes = [
      101,
      103,
      107,
      751,
      137,
      787,
      797,
      809,
      877,
      881,
      883,
      157,
      163,
      167,
      173,
      179,
      181,
      191,
      193,
      197,
      199,
      211,
      223,
      227,
      229,
      233,
      239,
      241
    ];
    return primes[index % primes.length];
  }

  static String _generateParityBit(String refCode) {
    if (refCode.length != 7) {
      return "-1";
    }

    String ALPHABETS = 'ABCDEFGHJKMNPQRTUVWXY346789';

    String _computeParity(
        String code, bool isLeftToRight, var primeMultipliers) {
      int total = 0;
      for (int i = 0; i < code.length; i++) {
        int digitIndex = isLeftToRight ? i : (code.length - (i + 1));
        int digit = _getPrimeForIndex(
            (ALPHABETS.indexOf(code[digitIndex]) + 1) *
                _getPrimeForIndex(pow(5 * (i + 1), 3) as int));

        total += (digit * primeMultipliers[i]) % (9007 + i) as int;
      }

      return ALPHABETS[total % 23];
    }

    var LEFT_2_RIGHT_PRIMES_1 = const [
      10039,
      10103,
      10151,
      10177,
      10259,
      10273,
      10337
    ];
    var LEFT_2_RIGHT_PRIMES_2 = const [
      90059,
      90067,
      90071,
      90073,
      90089,
      90107,
      90121,
      90127,
      90149
    ];
    var RIGHT_2_LEFT_PRIMES = const [
      74521,
      74527,
      74531,
      74551,
      74561,
      74567,
      74573,
      74587
    ];

    String rightParity1 = _computeParity(refCode, true, LEFT_2_RIGHT_PRIMES_1);
    String leftParity1 =
        _computeParity(refCode + rightParity1, false, RIGHT_2_LEFT_PRIMES);
    String rightParity2 = _computeParity(
        leftParity1 + refCode + rightParity1, true, LEFT_2_RIGHT_PRIMES_2);

    return rightParity1 + leftParity1 + rightParity2;
  }

  static bool isReferralCodeValid(String refCode) {
    if (refCode.length != 10) return false;
    refCode = refCode.toUpperCase();

    String leftParity = refCode[0];
    String rightParity1 = refCode[8];
    String rightParity2 = refCode[9];

    String parityBits = _generateParityBit(refCode.substring(1, 8));
    return leftParity == parityBits[1] &&
        rightParity1 == parityBits[0] &&
        rightParity2 == parityBits[2];
  }
}

@JsonSerializable()
class FlatAncestryNode extends FirebaseDocument {
  static const FIELD_CHILD_REFERRAL_CODE = "child_referral_code";
  static const FIELD_CHILD_ID = "child_id";
  static const FIELD_PARENT_REFERRAL_CODE = "parent_referral_code";
  static const FIELD_PARENT_ID = "parent_id";
  static const FIELD_SEPARATION = "separation";
  static const FIELD_DATE_REFERRAL = "date_referral";

  String? child_referral_code;
  String? child_id;
  String? parent_referral_code;
  String? parent_id;
  int? separation;

  @JsonKey(
      fromJson: FirebaseDocument.DateTimeFromJson,
      toJson: FirebaseDocument.DateTimeToJson)
  DateTime? date_referral;

  FlatAncestryNode();

  factory FlatAncestryNode.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    FlatAncestryNode node = FlatAncestryNode();

    var json = snapshot.data();
    if (json != null) {
      node = _$FlatAncestryNodeFromJson(json);
      node.documentID = snapshot.id;
    }

    return node;
  }

  Map<String, dynamic> toJson() => _$FlatAncestryNodeToJson(this);
}
