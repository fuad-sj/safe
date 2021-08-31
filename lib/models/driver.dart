import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/models/firebase_document.dart';

/// This allos this class to access private members in the generated files.
/// The value for this is .g.dart, where the star denotes the source file name.
part 'driver.g.dart';

@JsonSerializable()
class Driver extends Customer {
  static const FIREBASE_STORAGE_PATH_DRIVER_FILES = 'driver_files';

  static const FIELD_CAR_TYPE = 'car_type';

  static const FIELD_PROFILE_STATUS = 'profile_status';

  static const FIELD_CAR_COLOR = 'car_color';
  static const FIELD_CAR_NUMBER = 'car_number';
  static const FIELD_CAR_MODEL = 'car_model';

  static const FIELD_LINK_IMG_COMMON_PROFILE = 'link_img_common_profile';
  static const FIELD_IMG_STATUS_COMMON_PROFILE = 'img_status_common_profile';
  static const FIELD_LINK_IMG_COMMON_LIBRE = 'link_img_common_libre';
  static const FIELD_IMG_STATUS_COMMON_LIBRE = 'img_status_common_libre';
  static const FIELD_LINK_IMG_COMMON_DRIVING_LICENSE =
      'link_img_common_driving_license';
  static const FIELD_IMG_STATUS_COMMON_DRIVING_LICENSE =
      'img_status_common_driving_license';
  static const FIELD_LINK_IMG_COMMON_INSURANCE = 'link_img_common_insurance';
  static const FIELD_IMG_STATUS_COMMON_INSURANCE =
      'img_status_common_insurance';

  static const FIELD_IS_REPRESENTATIVE = 'is_representative';
  static const FIELD_LINK_IMG_COMMON_REPRESENTATIVE =
      'link_img_common_representative';
  static const FIELD_IMG_STATUS_COMMON_REPRESENTATIVE =
      'img_status_common_representative';

  static const FIELD_LINK_IMG_CODE_3_TIN_NUMBER = 'link_img_code_3_tin_number';
  static const FIELD_IMG_STATUS_CODE_3_TIN_NUMBER =
      'img_status_code_3_tin_number';
  static const FIELD_LINK_IMG_CODE_3_BUSINESS_LICENSE =
      'link_img_code_3_business_license';
  static const FIELD_IMG_STATUS_CODE_3_BUSINESS_LICENSE =
      'img_status_code_3_business_license';

  static const FIELD_LINK_IMG_CODE_1_MAHIBER_WUL =
      'link_img_code_1_mahiber_wul';
  static const FIELD_IMG_STATUS_CODE_1_MAHIBER_WUL =
      'img_status_code_1_mahiber_wul';

  // END field name declarations

  static const int CAR_TYPE_CODE_3 = 1;
  static const int CAR_TYPE_CODE_1 = 2;

  static const int PROFILE_STATUS_REJECTED = -11;
  static const int PROFILE_STATUS_UPLOADED = 1;
  static const int PROFILE_STATUS_UNDER_REVIEW = 2;
  static const int PROFILE_STATUS_COMMENTED_ON = 3;
  static const int PROFILE_STATUS_APPROVED = 4;

  static const int IMG_STATUS_NOT_UPLOADED = 1;
  static const int IMG_STATUS_ACCEPTED = 2;
  static const int IMG_STATUS_REJECTED = 3;

  int? car_type;

  int? profile_status;

  String? car_color;
  String? car_number;
  String? car_model;

  String? link_img_common_profile;
  int? img_status_common_profile;
  String? link_img_common_libre;
  int? img_status_common_libre;
  String? link_img_common_driving_license;
  int? img_status_common_driving_license;
  String? link_img_common_insurance;
  int? img_status_common_insurance;

  bool? is_representative;
  String? link_img_common_representative;
  int? img_status_common_representative;

  String? link_img_code_3_tin_number;
  int? img_status_code_3_tin_number;
  String? link_img_code_3_business_license;
  int? img_status_code_3_business_license;

  String? link_img_code_1_mahiber_wul;
  int? img_status_code_1_mahiber_wul;

  Driver();

  static String convertStoragePathToDriverPath(
      String driverID, String fieldName, String fileExtension) {
    return '${FIREBASE_STORAGE_PATH_DRIVER_FILES}/${driverID}_${fieldName}${fileExtension}';
  }

  factory Driver.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Driver driver = Driver();

    var json = snapshot.data();
    if (json != null) {
      driver = _$DriverFromJson(json);
      driver.documentID = snapshot.id;
    }

    return driver;
  }

  Map<String, dynamic> toJson() => _$DriverToJson(this);
}
