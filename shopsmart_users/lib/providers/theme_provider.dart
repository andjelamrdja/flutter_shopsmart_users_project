import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const TTHEME_STATUS = "TTHEME_STATUS";
  bool _darkTheme = false;
  bool get getIsDarkTheme => _darkTheme;

  ThemeProvider() {
    getTheme();
  }

  setDarkTheme({required bool themeValue}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(TTHEME_STATUS, themeValue);
    _darkTheme = themeValue;
    notifyListeners(); // da bi aplikacija registrovala promjenu teme
  }

  Future<bool> getTheme() async {
    // Future jer ne znamo kad ce tacno podaci biti dostupni
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _darkTheme = prefs.getBool(TTHEME_STATUS) ?? false;
    notifyListeners();
    return _darkTheme;
  }
}
