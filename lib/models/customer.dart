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

  static const FIELD_DATE_CREATED = 'date_created';
  static const FIELD_DATE_LAST_LOGIN = 'date_last_login';

  static const FIELD_IS_ACTIVE = 'is_active';

  static const FIELD_IS_LOGGED_IN = 'is_logged_in';

  static const FIELD_DEVICE_REGISTRATION_TOKENS = 'device_registration_tokens';

  static const FIELD_LINK_IMG_PROFILE = 'link_img_profile';

  // END field name declarations

  String? phone_number;
  String? user_name;
  String? email;

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
}
