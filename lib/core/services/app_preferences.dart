import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('AppPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Define keys here
  static const String keyTheme = 'theme';
  static const String keyThemePreset = 'theme_preset';
  static const String keyPureDark = 'pure_dark';
  static const String keyDoubleTapToExit = 'double_tap_to_exit';
  static const String keyAppProtectionEnabled = 'app_protection_enabled';
  static const String keyAppProtectionType =
      'app_protection_type'; // 'biometrics' or 'pin'
  static const String keyBackupLocation = 'backup_location';

  // Helper methods
  static String? getString(String key) => instance.getString(key);
  static Future<bool> setString(String key, String value) =>
      instance.setString(key, value);
  static bool? getBool(String key) => instance.getBool(key);
  static Future<bool> setBool(String key, bool value) =>
      instance.setBool(key, value);

  static String exportToJson() {
    final Map<String, dynamic> prefsMap = {};
    for (String key in instance.getKeys()) {
      prefsMap[key] = instance.get(key);
    }
    return jsonEncode(prefsMap);
  }

  static Future<void> importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> prefsMap = jsonDecode(jsonString);
      for (var entry in prefsMap.entries) {
        if (entry.value is bool) {
          await instance.setBool(entry.key, entry.value as bool);
        } else if (entry.value is String) {
          await instance.setString(entry.key, entry.value as String);
        } else if (entry.value is int) {
          await instance.setInt(entry.key, entry.value as int);
        } else if (entry.value is double) {
          await instance.setDouble(entry.key, entry.value as double);
        } else if (entry.value is List) {
          await instance.setStringList(
            entry.key,
            (entry.value as List).cast<String>(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error importing preferences: $e');
    }
  }
}
