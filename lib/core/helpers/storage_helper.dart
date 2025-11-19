import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Storage Helper for managing offline prayer time data
class StorageHelper {
  static const String _prayerTimesKey = 'cached_prayer_times';
  static const String _lastUpdateKey = 'last_update_time';
  static const String _cachedDateKey = 'cached_date';
  
  /// Save prayer times data to local storage
  static Future<void> savePrayerTimes(Map<String, dynamic> prayerData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save prayer data
    await prefs.setString(_prayerTimesKey, json.encode(prayerData));
    
    // Save update timestamp
    await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    
    // Save the date for which these times are cached
    if (prayerData['date'] != null && prayerData['date']['gregorian'] != null) {
      await prefs.setString(_cachedDateKey, prayerData['date']['gregorian']['date']);
    }
  }
  
  /// Get cached prayer times from local storage
  static Future<Map<String, dynamic>?> getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_prayerTimesKey);
    
    if (cachedData != null) {
      try {
        return json.decode(cachedData);
      } catch (e) {
        // If data is corrupted, return null
        return null;
      }
    }
    return null;
  }
  
  /// Get the last update time
  static Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString(_lastUpdateKey);
    
    if (lastUpdate != null) {
      try {
        return DateTime.parse(lastUpdate);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// Check if cached data is for today
  static Future<bool> isCachedDataForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedDate = prefs.getString(_cachedDateKey);
    
    if (cachedDate != null) {
      // Format today's date to match the API format (DD-MM-YYYY)
      final now = DateTime.now();
      final todayFormatted = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      
      return cachedDate == todayFormatted;
    }
    return false;
  }
  
  /// Clear all cached data
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prayerTimesKey);
    await prefs.remove(_lastUpdateKey);
    await prefs.remove(_cachedDateKey);
  }

  /// Generic method to get string value
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Generic method to save string value
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Get list value
  static Future<List<dynamic>?> getList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null) return null;
    return json.decode(value) as List<dynamic>;
  }

  /// Save list value
  static Future<void> saveList(String key, List<dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
  }

  /// Get map value
  static Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null) return null;
    return json.decode(value) as Map<String, dynamic>;
  }

  /// Save map value
  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(value));
  }

  /// Get boolean value
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Save boolean value
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Remove a key
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Get location settings (from legacy model)
  static Future<dynamic> getLocationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('location_settings');
    if (value == null) return null;
    return json.decode(value);
  }
}