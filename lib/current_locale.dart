import 'package:flutter/material.dart';

class CurrentLocale extends ChangeNotifier {
  Locale _locale = Locale('en');

  CurrentLocale(String localeID) {
    _locale = Locale(localeID);
  }

  Locale get getLocale => _locale;

  void setLocale(String localeID) {
    _locale = Locale(localeID);
    notifyListeners();
  }
}
