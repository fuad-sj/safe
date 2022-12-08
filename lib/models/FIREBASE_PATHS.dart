class FIREBASE_DB_PATHS {
  static final PATH_VEHICLE_LOCATIONS = 'vehicle_locations';
}

class FIRESTORE_PATHS {
  static final COL_CUSTOMERS = 'customers';
  static final SUB_COL_CUSTOMERS_RIDE_HISTORY = 'sub_customer_ride_history';

  static final COL_REFERRAL_REQUEST = 'referral_request';

  static final COL_DRIVERS = 'drivers';
  static final SUB_COL_DRIVERS_RIDE_HISTORY = 'driver_ride_history';

  static final COL_RIDES = 'rides';

  static final COL_CONFIG = 'config';
  static final DOC_CONFIG = 'CONFIGURATION';

  static final COL_OTP_REQUESTS = "otp_requests";
}

class FCM_MESSAGING_TOPICS {
  static final TOPIC_ALL_DRIVERS = 'all_drivers';
  static final TOPIC_ALL_CUSTOMERS = 'all_customers';
}
