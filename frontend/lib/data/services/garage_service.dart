import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/car_model.dart';
import '../cache/cache_service.dart';
import '../mock/mock_data.dart';

/// Garage Service для работы с /api/v1/garage endpoints
///
/// Endpoints:
/// - GET /garage - Список гаражей
/// - POST /garage - Создать гараж
/// - GET /garage/:id - Получить гараж
/// - PUT /garage/:id - Обновить гараж
/// - DELETE /garage/:id - Удалить гараж
class GarageService {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  GarageService(this._apiClient, this._cacheService);

  /// Получить список всех гаражей пользователя
  Future<List<CarModel>> getGarages() async {
    try {
      final response = await _apiClient.get('/garage');
      if (response.data is! List) {
        debugPrint('⚠️ Backend not implemented, using mock data');
        return MockData.mockVehicles;
      }

      final List<dynamic> data = response.data as List;
      final cars = data.map((json) => CarModel.fromJson(json)).toList();
      await _cacheService.saveCars(cars);
      return cars;
    } catch (e) {
      debugPrint('⚠️ Failed to load from backend: $e, using mock data');
      return MockData.mockVehicles;
    }
  }

  /// Получить конкретный гараж по ID
  Future<CarModel> getGarage(String id) async {
    final response = await _apiClient.get('/garage/$id');
    return CarModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Создать новый гараж
  Future<CarModel> createGarage({
    required String name,
    required String make,
    required String model,
    required int year,
    String? vin,
    String? plateNumber,
    int? mileage,
  }) async {
    final response = await _apiClient.post(
      '/garage',
      data: {
        'name': name,
        'make': make,
        'model': model,
        'year': year,
        if (vin != null) 'vin': vin,
        if (plateNumber != null) 'plate_number': plateNumber,
        if (mileage != null) 'mileage': mileage,
      },
    );

    return CarModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Обновить гараж
  Future<CarModel> updateGarage(
    String id, {
    String? name,
    int? mileage,
    String? notes,
  }) async {
    final response = await _apiClient.put(
      '/garage/$id',
      data: {
        if (name != null) 'name': name,
        if (mileage != null) 'mileage': mileage,
        if (notes != null) 'notes': notes,
      },
    );

    return CarModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Удалить гараж
  Future<void> deleteGarage(String id) async {
    await _apiClient.delete('/garage/$id');
  }
}
