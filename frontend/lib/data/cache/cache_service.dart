import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_model.dart';
import '../models/maintenance_model.dart';

class CacheService {
  static const _carsKey = 'cache_cars';
  static const _maintenancePrefix = 'cache_maintenance_';

  Future<void> saveCars(List<CarModel> cars) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cars.map((car) => car.toJson()).toList();
    await prefs.setString(_carsKey, jsonEncode(jsonList));
  }

  Future<List<CarModel>> loadCars() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_carsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => CarModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMaintenance(
    String garageId,
    List<MaintenanceModel> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString('$_maintenancePrefix$garageId', jsonEncode(jsonList));
  }

  Future<List<MaintenanceModel>> loadMaintenance(String garageId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_maintenancePrefix$garageId');
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => MaintenanceModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
