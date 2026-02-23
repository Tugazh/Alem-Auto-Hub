import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/maintenance_model.dart';
import '../cache/cache_service.dart';
import '../mock/mock_data.dart';

/// Maintenance Service для работы с /api/v1/maintenance endpoints
///
/// Endpoints:
/// - GET /maintenance - Список записей обслуживания
/// - POST /maintenance - Создать запись
/// - GET /maintenance/:id - Получить запись
/// - PUT /maintenance/:id - Обновить запись
/// - DELETE /maintenance/:id - Удалить запись
/// - GET /maintenance/schedule - Расписание обслуживания
class MaintenanceService {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  MaintenanceService(this._apiClient, this._cacheService);

  /// Получить список обслуживаний для гаража
  Future<List<MaintenanceModel>> getMaintenanceList({
    required String garageId,
    String? status, // 'pending', 'completed', 'overdue'
  }) async {
    try {
      final response = await _apiClient.get(
        '/maintenance',
        queryParameters: {
          'garage_id': garageId,
          if (status != null) 'status': status,
        },
      );

      if (response.data is! List) {
        debugPrint('⚠️ Backend not implemented, using mock data');
        return MockData.mockMaintenanceRecords;
      }

      final List<dynamic> data = response.data as List;
      final items = data
          .map((json) => MaintenanceModel.fromJson(json))
          .toList();
      await _cacheService.saveMaintenance(garageId, items);
      return items;
    } catch (e) {
      debugPrint('⚠️ Failed to load from backend: $e, using mock data');
      return MockData.mockMaintenanceRecords;
    }
  }

  /// Получить конкретную запись обслуживания
  Future<MaintenanceModel> getMaintenance(String id) async {
    final response = await _apiClient.get('/maintenance/$id');
    return MaintenanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Создать новую запись обслуживания
  Future<MaintenanceModel> createMaintenance({
    required String garageId,
    required String type, // 'oil_change', 'tire_rotation', etc.
    required DateTime scheduledDate,
    String? notes,
    double? cost,
  }) async {
    final response = await _apiClient.post(
      '/maintenance',
      data: {
        'garage_id': garageId,
        'type': type,
        'scheduled_date': scheduledDate.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (cost != null) 'cost': cost,
      },
    );

    return MaintenanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Обновить запись обслуживания
  Future<MaintenanceModel> updateMaintenance(
    String id, {
    DateTime? completedDate,
    String? status,
    double? actualCost,
    String? notes,
  }) async {
    final response = await _apiClient.put(
      '/maintenance/$id',
      data: {
        if (completedDate != null)
          'completed_date': completedDate.toIso8601String(),
        if (status != null) 'status': status,
        if (actualCost != null) 'actual_cost': actualCost,
        if (notes != null) 'notes': notes,
      },
    );

    return MaintenanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Удалить запись обслуживания
  Future<void> deleteMaintenance(String id) async {
    await _apiClient.delete('/maintenance/$id');
  }

  /// Получить расписание обслуживания
  Future<Map<String, dynamic>> getSchedule({required String garageId}) async {
    final response = await _apiClient.get(
      '/maintenance/schedule',
      queryParameters: {'garage_id': garageId},
    );

    return response.data as Map<String, dynamic>;
  }
}
