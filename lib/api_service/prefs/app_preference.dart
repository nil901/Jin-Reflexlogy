import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PreferencesKey.dart';

class AppPreference {
  static final AppPreference _appPreference = AppPreference._internal();

  factory AppPreference() {
    return _appPreference;
  }

  AppPreference._internal();

  SharedPreferences? _preferences;

  Future<void> initialAppPreference() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> remove(String key) async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.remove(key);
  }

  Future<void> setString(String key, String value) async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setString(key, value);
  }

  String getString(String key, {String defValue = ''}) {
    return _preferences?.getString(key) ?? defValue;
  }

  Future<void> setInt(String key, int value) async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setInt(key, value);
  }

  int getInt(String key, {int defValue = 0}) {
    return _preferences?.getInt(key) ?? defValue;
  }

  Future<void> setBool(String key, bool value) async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.setBool(key, value);
  }

  bool getBool(String key, {bool defValue = false}) {
    return _preferences?.getBool(key) ?? defValue;
  }

  Future<void> clearSharedPreferences() async {
    _preferences ??= await SharedPreferences.getInstance();

    final authKeys = <String>{
      PreferencesKey.token,
      PreferencesKey.userId,
      PreferencesKey.name,
      PreferencesKey.email,
      PreferencesKey.contactNumber,
      PreferencesKey.type,
    };

    for (final key in authKeys) {
      await _preferences!.remove(key);
    }

    debugPrint('Logout: removed auth/session data only');
  }

  Future<void> clearDiagnosisDrafts({String? patientId}) async {
    _preferences ??= await SharedPreferences.getInstance();
    final allKeys = _preferences!.getKeys();
    final toRemove = <String>[];
    for (final key in allKeys) {
      if (key.startsWith("LF_DATA") ||
          key.startsWith("RF_DATA") ||
          key.startsWith("LH_DATA") ||
          key.startsWith("RH_DATA") ||
          key.startsWith("LF_IMG") ||
          key.startsWith("RF_IMG") ||
          key.startsWith("LH_IMG") ||
          key.startsWith("RH_IMG") ||
          key.startsWith("LF_SAVED") ||
          key.startsWith("RF_SAVED") ||
          key.startsWith("LH_SAVED") ||
          key.startsWith("RH_SAVED")) {
        if (patientId != null && patientId.isNotEmpty) {
          if (key.endsWith("_$patientId")) {
            toRemove.add(key);
          }
        } else {
          toRemove.add(key);
        }
      }
    }
    for (final key in toRemove) {
      await _preferences!.remove(key);
    }
    debugPrint("🧹 AppPreference: Cleared ${toRemove.length} diagnosis draft keys: $toRemove");
  }

  String get uName => getString(PreferencesKey.token);
}
