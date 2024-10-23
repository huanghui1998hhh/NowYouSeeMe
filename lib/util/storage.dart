import 'package:shared_preferences/shared_preferences.dart';

abstract class Storage {
  static SharedPreferences? __instance;
  static SharedPreferences get _instance =>
      __instance ?? (throw Exception('Storage not initialized'));
  static Future<void> init() async {
    __instance = await SharedPreferences.getInstance();
  }

  static String? getString(String key) => _instance.getString(key);
  static Future<bool> setString(String key, String value) =>
      _instance.setString(key, value);

  static int? getInt(String key) => _instance.getInt(key);
  static Future<bool> setInt(String key, int value) =>
      _instance.setInt(key, value);
}

abstract class StorageKeys {
  static const themeMode = 'theme_mode';
}
