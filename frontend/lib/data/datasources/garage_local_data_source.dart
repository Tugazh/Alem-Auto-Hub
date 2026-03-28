import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car_model.dart';

/// Local data source for caching vehicles
/// Uses SharedPreferences for persistence
abstract class GarageLocalDataSource {
  Future<List<CarModel>?> getCachedVehicles();
  Future<void> cacheVehicles(List<CarModel> vehicles);
  Future<void> clearCache();
}

class GarageLocalDataSourceImpl implements GarageLocalDataSource {
  static const String _cacheKey = 'cached_vehicles';
  static const String _timestampKey = 'cached_vehicles_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);

  final SharedPreferences _prefs;

  GarageLocalDataSourceImpl({required SharedPreferences prefs})
    : _prefs = prefs;

  @override
  Future<List<CarModel>?> getCachedVehicles() async {
    try {
      // Check if cache exists and is not expired
      final timestampMs = _prefs.getInt(_timestampKey);
      if (timestampMs == null) {
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      final now = DateTime.now();

      if (now.difference(cacheTime) > _cacheExpiry) {
        // Cache expired
        await clearCache();
        return null;
      }

      // Read cached data
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null) {
        return null;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CarModel.fromJson(json)).toList();
    } catch (e) {
      // If parsing fails, clear corrupted cache
      await clearCache();
      return null;
    }
  }

  @override
  Future<void> cacheVehicles(List<CarModel> vehicles) async {
    try {
      final jsonList = vehicles.map((v) => v.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await _prefs.setString(_cacheKey, jsonString);
      await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail cache write
      // ignore: avoid_print
      print('Failed to cache vehicles: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_timestampKey);
  }
}
