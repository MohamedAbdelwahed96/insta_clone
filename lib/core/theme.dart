import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.white, /// Background
      primary: Colors.black, /// Text
      secondary: Color.fromRGBO(32, 32, 32, 1), /// HintText
      inversePrimary: Color.fromRGBO(217, 217, 217, 1), /// TextFormField Background
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.black, /// Background
      primary: Colors.white, /// Text
      secondary: Color.fromRGBO(223, 223, 223, 1), /// HintText
      inversePrimary: Color.fromRGBO(38, 38, 38, 1), /// TextFormField Background
    ));

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  static const String themeKey = "isDarkMode";
  ThemeProvider(this._themeData);

  Future<void> _saveTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, isDarkMode);
  }

  Future loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool(themeKey) ?? false;
    _themeData = isDarkMode ? darkMode : lightMode;
    notifyListeners();
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    bool isDarkMode = _themeData == lightMode;
    _themeData = isDarkMode ? darkMode : lightMode;
    _saveTheme(!isDarkMode);
    notifyListeners();
  }
}
