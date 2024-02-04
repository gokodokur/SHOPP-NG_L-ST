import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeViewModel with ChangeNotifier {
  static const THEME_KEY = "THEME_KEY";
  late ThemeMode _themeMode;
  late SharedPreferences _preferences;
  ThemeMode get themeMode => _themeMode;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  AppThemeViewModel() {
    _themeMode = ThemeMode.light;
    getPreferences();
  }

//Temalar arası değişiklik yapma
  set themeMode(ThemeMode value) {
    _themeMode = value;
    _preferences.setString(THEME_KEY, value.name);
    notifyListeners();
  }

  getPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    _themeMode = _preferences.getString(THEME_KEY) == "light"
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }
}
