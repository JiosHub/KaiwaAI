import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String isLoggedInKey = "isLoggedIn";
  static final String usernameKey = "username";
  static final String personalAPIKey = "personalAPIKey";
  static final String selectedGPT = "selectedGPT";

  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  static Future<void> setAPIKey(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(personalAPIKey, username);
  }

  static Future<String?> getAPIKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(personalAPIKey);
  }

  static Future<void> setSelectedGPT(String valueGPT) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedGPT, valueGPT);
  }

  static Future<String?> getSelectedGPT() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedGPT);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<void> setIsLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }
}