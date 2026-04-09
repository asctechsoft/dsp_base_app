@Deprecated("Use 'package:dsp_base/convenience_imports.dart' instead")
library;

import "package:shared_preferences/shared_preferences.dart";

class PrefAssist {
  static SharedPreferences? pref;

  static String Function(String)? defaultValueString;
  static List<String> Function(String)? defaultValueStringList;
  static int Function(String)? defaultValueInt;
  static bool Function(String)? defaultValueBoolean;
  static double Function(String)? defaultValueDouble;

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  static bool isKeyExist(String key) {
    return pref?.containsKey(key) ?? false;
  }

  static Future<void> removeKey(String key) async {
    await pref?.remove(key);
  }

  static String getString(String key, {String? defaultValue}) {
    return pref?.getString(key) ?? defaultValue ?? (defaultValueString != null ? defaultValueString!.call(key) : "");
  }

  static Future<void> setString(String key, String data) async {
    await pref?.setString(key, data);
  }

  static int getInt(String key, {int? defaultValue}) {
    return pref?.getInt(key) ?? defaultValue ?? (defaultValueInt != null ? defaultValueInt!.call(key) : 0);
  }

  static Future<void> setInt(String key, int data) async {
    await pref?.setInt(key, data);
  }

  static bool getBoolean(String key, {bool? defaultValue}) {
    return pref?.getBool(key) ?? defaultValue ?? (defaultValueBoolean != null ? defaultValueBoolean!.call(key) : false);
  }

  static Future<void> setBoolean(String key, bool data) async {
    await pref?.setBool(key, data);
  }

  static double getDouble(String key, {double? defaultValue}) {
    return pref?.getDouble(key) ?? defaultValue ?? (defaultValueDouble != null ? defaultValueDouble!.call(key) : 0.0);
  }

  static Future<void> setDouble(String key, double data) async {
    await pref?.setDouble(key, data);
  }

  static Future<void> clear() async {
    await pref?.clear();
  }

  static List<String> getStringList(String key, {List<String>? defaultValue}) {
    return pref?.getStringList(key) ??
        defaultValue ??
        (defaultValueStringList != null ? defaultValueStringList!.call(key) : []);
  }

  static Future<void> setStringList(String key, List<String> data) async {
    await pref?.setStringList(key, data);
  }
}
