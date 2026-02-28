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
  static const String keyBackupLocation = 'backup_location';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // Helper methods
  static String? getPreference(String key) => instance.getString(key);
  static Future<bool> setPreference(String key, String value) =>
      instance.setString(key, value);
  static bool? getPreferenceBool(String key) => instance.getBool(key);
  static Future<bool> setPreferenceBool(String key, bool value) =>
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
        switch (entry.value) {
          case bool value:
            await instance.setBool(entry.key, value);
            break;
          case String value:
            await instance.setString(entry.key, value);
            break;
          case int value:
            await instance.setInt(entry.key, value);
            break;
          case double value:
            await instance.setDouble(entry.key, value);
            break;
          case List value:
            await instance.setStringList(entry.key, value.cast<String>());
            break;
          default:
            break;
        }
      }
    } catch (e) {
      debugPrint('Error importing preferences: $e');
    }
  }
}
