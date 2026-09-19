import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clean abstraction for local persistent key-value storage.
/// Uses SharedPreferences with an in-memory fallback for high reliability
/// and effortless unit testing without platform channel dependencies.
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;
  final Map<String, String> _memoryFallback = {};

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize persistent storage on app startup
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('[StorageService] Error initializing SharedPreferences, using memory fallback: $e');
    }
  }

  /// Allows injecting a mock or pre-initialized instance for testing
  @visibleForTesting
  static void setMockInstance(StorageService mock) {
    _instance = mock;
  }

  Future<bool> setString(String key, String value) async {
    _memoryFallback[key] = value;
    if (_prefs != null) {
      try {
        return await _prefs!.setString(key, value);
      } catch (e) {
        debugPrint('[StorageService] setString failed for $key: $e');
      }
    }
    return true;
  }

  String? getString(String key) {
    if (_prefs != null) {
      try {
        final val = _prefs!.getString(key);
        if (val != null) return val;
      } catch (e) {
        debugPrint('[StorageService] getString failed for $key: $e');
      }
    }
    return _memoryFallback[key];
  }

  Future<bool> setBool(String key, bool value) async {
    return setString(key, value.toString());
  }

  bool? getBool(String key) {
    final str = getString(key);
    if (str == null) return null;
    return str.toLowerCase() == 'true';
  }

  Future<bool> setJson(String key, Map<String, dynamic> jsonMap) async {
    try {
      final jsonString = jsonEncode(jsonMap);
      return await setString(key, jsonString);
    } catch (e) {
      debugPrint('[StorageService] Failed to serialize JSON for $key: $e');
      return false;
    }
  }

  Map<String, dynamic>? getJson(String key) {
    final str = getString(key);
    if (str == null || str.isEmpty) return null;
    try {
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint('[StorageService] Failed to decode JSON for $key: $e');
    }
    return null;
  }

  Future<bool> setJsonList(String key, List<Map<String, dynamic>> list) async {
    try {
      final jsonString = jsonEncode(list);
      return await setString(key, jsonString);
    } catch (e) {
      debugPrint('[StorageService] Failed to serialize JSON list for $key: $e');
      return false;
    }
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final str = getString(key);
    if (str == null || str.isEmpty) return null;
    try {
      final decoded = jsonDecode(str);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      debugPrint('[StorageService] Failed to decode JSON list for $key: $e');
    }
    return null;
  }

  Future<bool> remove(String key) async {
    _memoryFallback.remove(key);
    if (_prefs != null) {
      try {
        return await _prefs!.remove(key);
      } catch (e) {
        debugPrint('[StorageService] remove failed for $key: $e');
      }
    }
    return true;
  }

  Future<bool> clear() async {
    _memoryFallback.clear();
    if (_prefs != null) {
      try {
        return await _prefs!.clear();
      } catch (e) {
        debugPrint('[StorageService] clear failed: $e');
      }
    }
    return true;
  }
}
