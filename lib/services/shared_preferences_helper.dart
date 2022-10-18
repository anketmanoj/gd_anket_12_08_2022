import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:sizer/sizer.dart';

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

  static setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  static setListString(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  static setRecommendedOptions(String key, List<String> value) async {
    await prefs.setStringList(key, value);
  }

  static String getString(String key) {
    return prefs.getString(key) ?? "";
  }

  static bool getBool(String key) {
    return prefs.getBool(key) ?? false;
  }

  static List<String> getListString(String key) {
    return prefs.getStringList(key) ?? [""];
  }

  static List<String> getRecommendedOptions(String key) {
    return prefs.getStringList(key) ?? [];
  }

  static clearSharedPrefs() async {
    await prefs.clear();
  }

  static setDyValue(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  static getDyValue(String key) {
    return prefs.getDouble(key) ?? 0;
  }

  static setDxValue(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  static getDxValue(String key) {
    return prefs.getDouble(key) ?? 0;
  }
}
