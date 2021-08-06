import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

class PrefUtil {
  static PrefUtil? _singleton;
  static late SharedPreferences _prefs;
  static late Lock _lock = Lock();

  PrefUtil._();

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<PrefUtil> getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if (_singleton == null) {
          var single = PrefUtil._();
          await single._init();
          _singleton = single;
        }
      });
    }

    return _singleton!;
  }

  static const int LANGUAGE_NONE = 0;
  static const int LANGUAGE_AMHARIC = 1;
  static const int LANGUAGE_ENGLISH = 2;

  static String getCurrentUserID() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  static String getCurrentUserPhone() {
    return FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
  }

  static const String pref_key_company_id = "pref_key_company_id";
  static Future<void> saveCurrentCompanyID(String companyId) async {
    await _prefs.setString(pref_key_company_id, companyId);
  }

  static String getCurrentCompanyID() {
    return _prefs.getString(pref_key_company_id) ?? '';
  }

  static bool isCompanyIDSet() {
    return getCurrentCompanyID().isNotEmpty;
  }

  static const int LOGIN_STATUS_SIGNED_OUT = -1;
  static const int LOGIN_STATUS_PREVIOUSLY_LOGGED_IN = 1;
  static const int LOGIN_STATUS_LOGIN_JUST_NOW = 2;

  static const String pref_login_status = "pref_login_status";

  static int getLoginStatus() {
    return _prefs.getInt(pref_login_status) ?? LOGIN_STATUS_SIGNED_OUT;
  }

  static Future<void> setLoginStatus(int status) async {
    await _prefs.setInt(pref_login_status, status);
  }

  static const String pref_user_language_locale = "pref_user_language_locale";

  Future<void> setUserLanugageLocale(int localeId) async {
    await _prefs.setInt(pref_user_language_locale, localeId);
  }

  static int getUserLanguageLocaleID() {
    return _prefs.getInt(pref_user_language_locale) ?? LANGUAGE_NONE;
  }

  static bool isUserLanguageSet() {
    return getUserLanguageLocaleID() != LANGUAGE_NONE;
  }
}
