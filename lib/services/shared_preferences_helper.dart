import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  static late SharedPreferences prefs;

  static initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  static setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  static int getInt(String key) {
    return prefs.getInt(key) ?? 0;
  }

  static setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String getString(String key) {
    return prefs.getString(key) ?? "";
  }

  static clearSharedPrefs() async {
    await prefs.clear();
  }
}
