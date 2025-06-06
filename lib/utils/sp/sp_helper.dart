import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPHelper {
  static SharedPreferences? sp;
  static init() async {
    sp ??= await SharedPreferences.getInstance();
  }
  static T? getPreference<T>(String key, T defaultValue) {
    try {
      if (defaultValue is String) {
        return sp?.getString(key) as T;
      } else if (defaultValue is bool) {
        return sp?.getBool(key) as T;
      } else if (defaultValue is int) {
        return sp?.getInt(key) as T;
      } else if (defaultValue is double) {
        return sp?.getDouble(key) as T;
      } else if (defaultValue is List<String>) {
        return sp?.getDouble(key) as T;
      }
    } catch (e) {
      printLog(msg:"SP helper getPreference: $key $defaultValue $e");
    }
    return defaultValue;
  }

  static Future<Future<bool>?> setPreference<T>(String key, T value) async {
    try {
      if (value is String) {
        return sp?.setString(key, value);
      } else if (value is bool) {
        return sp?.setBool(key, value);
      } else if (value is int) {
        return sp?.setInt(key, value);
      } else if (value is double) {
        return sp?.setDouble(key, value);
      } else if (value is double) {
        return sp?.setDouble(key, value);
      } else if (value is List<String>) {
        return sp?.setStringList(key, value);
      }
    } catch (e) {
      printLog(msg:"SP helper setPreference: $key $value $e");
    }
    return null;
  }

  static Future<Set<String>?> getAllKeys() async {
    try {
      return sp?.getKeys();
    } catch (e) {
      printLog(msg:e.toString());
    }
    return null;
  }

  static Future<Future<bool>?> removeKey(String key) async {
    try {
      return sp?.remove(key);
    } catch (e) {
      printLog(msg:e.toString());
    }
    return null;
  }

  static Future<Future<bool>?> clearPreference() async {
    try {
      return sp?.clear();
    } catch (e) {
      printLog(msg:e.toString());
    }
    return null;
  }

  static Future<bool?> keyExist(String key) async {
    try {
      return sp?.containsKey(key);
    } catch (e) {
      printLog(msg:e.toString());
    }
    return null;
  }
}
