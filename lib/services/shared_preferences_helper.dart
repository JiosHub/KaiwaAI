import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String isLoggedInKey = "isLoggedIn";

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<void> setIsLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }
}