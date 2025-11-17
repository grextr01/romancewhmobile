import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class CacheData {
  static late SharedPreferences _sharedPreferences;

 static Future<void> cacheInitialization() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> setData(String key, dynamic value) async {
    if (value is int) {
      await _sharedPreferences.setInt(key, value);
      return true;
    }
    if (value is bool) {
      await _sharedPreferences.setBool(key, value);
      return true;
    }
    if (value is String) {
      await _sharedPreferences.setString(key, value);
      return true;
    }
    if (value is double) {
      await _sharedPreferences.setDouble(key, value);
      return true;
    }
    if (value is List<String>) {
      await _sharedPreferences.setStringList(key, value);
      return true;
    }
    return false;
  }

  static dynamic getData(String key) {
    return _sharedPreferences.get(key);
  }

  static void deleteItem(String key){
    _sharedPreferences.remove(key);
  }
}