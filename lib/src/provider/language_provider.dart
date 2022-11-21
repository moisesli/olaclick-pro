import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _appLocale = Locale('pt');

  Locale get appLocal => _appLocale;

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('pt');
      return null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    return null;
  }

  void addNewLanguage() async {}

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    //conditional to select language
    if (type == Locale("en")) {
      _appLocale = Locale("en");
      prefs.setString('language_code', 'en');
    } else if (type == Locale("es")) {
      _appLocale = Locale("es");
      prefs.setString('language_code', 'es');
    } else if (type == Locale("fr")) {
      _appLocale = Locale("fr");
      prefs.setString('language_code', 'fr');
    } else if (type == Locale("pt")) {
      _appLocale = Locale("pt");
      prefs.setString('language_code', 'pt');
    }
    notifyListeners();
  }
}
