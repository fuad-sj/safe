class FIREBASE_DB_PATHS {
  static final PATH_VEHICLE_LOCATIONS = 'vehicle_locations';
}

class FIRESTORE_PATHS {
  static final COL_CUSTOMERS = 'customers';
  static final SUB_COL_CUSTOMERS_RIDE_HISTORY = 'sub_customer_ride_history';

  static final COL_REFERRAL_REQUEST = 'referral_request';
  static final COL_FLAT_REFERRAL_TREE = "flat_referral_tree";

  static final COL_DRIVERS = 'drivers';
  static final SUB_COL_DRIVERS_RIDE_HISTORY = 'driver_ride_history';

  static final COL_RIDES = 'rides';

  static final COL_CONFIG = 'config';
  static final DOC_CONFIG = 'CONFIGURATION';

  static final COL_UPDATE_VERSIONS = "update_versions";
  static final DOC_UPDATE_VERSIONS_CUSTOMERS = "CUSTOMERS";
  static final DOC_UPDATE_VERSIONS_DRIVERS = "DRIVERS";
  static final SUB_COL_UPDATE_VERSION_CUSTOMERS =
      "sub_update_version_customers";
  static final SUB_COL_UPDATE_VERSION_DRIVERS = "sub_update_version_drivers";

  static final COL_OTP_REQUESTS = "otp_requests";

  static final COL_REFERRAL_TRAVERSED_TREE = "referral_traversed_tree";
  static final COL_REFERRAL_DAILY_EARNINGS = "referral_daily_earnings";
  static final COL_REFERRAL_CURRENT_BALANCE = "referral_current_balance";
  static final COL_REFERRAL_TRANSACTION_LOG = "referral_transaction_log";

  static final COL_REFERRAL_PAYMENT_REQUESTS = "referral_payment_requests";
}

class FCM_MESSAGING_TOPICS {
  static final TOPIC_ALL_DRIVERS = 'all_drivers';
  static final TOPIC_ALL_CUSTOMERS = 'all_customers';
}
