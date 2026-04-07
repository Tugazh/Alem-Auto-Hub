import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/fine_model.dart';

/// Fines Service для работы с /api/v1/fines
///
/// Backend endpoints:
/// - POST /fines - Создать штраф
/// - GET /fines - Список штрафов (с фильтрами)
/// - GET /fines/:id - Получить штраф
/// - PUT /fines/:id - Обновить штраф (статус, дата оплаты)
/// - DELETE /fines/:id - Удалить штраф
class FinesService {
  final ApiClient _apiClient;

  FinesService(this._apiClient);

  /// Получить список штрафов
  Future<List<FineModel>> getFines({String? vehicleId, String? status}) async {
    try {
      final response = await _apiClient.get(
        '/fines',
        queryParameters: {
          if (vehicleId != null) 'vehicle_id': vehicleId,
          if (status != null) 'status': status,
        },
      );

      if (response.data is! List) {
        debugPrint('⚠️ Fines API: unexpected response format');
        return [];
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => FineModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to load fines: $e');
      return [];
    }
  }

  /// Получить штраф по ID
  Future<FineModel?> getFine(String id) async {
    try {
      final response = await _apiClient.get('/fines/$id');
      return FineModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to load fine: $e');
      return null;
    }
  }

  /// Создать новый штраф
  Future<FineModel?> createFine({
    String? vehicleId,
    required double amount,
    String currency = 'KZT',
    String? article,
    required String description,
    required DateTime issuedAt,
  }) async {
    try {
      final response = await _apiClient.post(
        '/fines',
        data: {
          if (vehicleId != null) 'vehicle_id': vehicleId,
          'amount': amount,
          'currency': currency,
          if (article != null) 'article': article,
          'description': description,
          'issued_at': issuedAt.toIso8601String().split('T')[0], // YYYY-MM-DD
        },
      );

      return FineModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to create fine: $e');
      return null;
    }
  }

  /// Обновить штраф (отметить как оплаченный)
  Future<FineModel?> updateFine({
    required String id,
    String? status,
    DateTime? paidAt,
  }) async {
    try {
      final response = await _apiClient.put(
        '/fines/$id',
        data: {
          if (status != null) 'status': status,
          if (paidAt != null) 'paid_at': paidAt.toIso8601String(),
        },
      );

      return FineModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to update fine: $e');
      return null;
    }
  }

  /// Оплатить штраф
  Future<bool> payFine(String id) async {
    final result = await updateFine(
      id: id,
      status: 'paid',
      paidAt: DateTime.now(),
    );
    return result != null;
  }

  /// Удалить штраф
  Future<bool> deleteFine(String id) async {
    try {
      await _apiClient.delete('/fines/$id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete fine: $e');
      return false;
    }
  }
}
