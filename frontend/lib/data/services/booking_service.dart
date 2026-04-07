import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/booking_model.dart';

/// Сервис бронирований для работы с /api/v1/bookings.
///
/// Эндпоинты бекенда:
/// - POST /bookings - Создать бронирование
/// - GET /bookings - Список бронирований (с фильтрами)
/// - GET /bookings/:id - Получить бронирование
/// - PATCH /bookings/:id - Обновить бронирование (статус, заметки)
/// - DELETE /bookings/:id - Удалить бронирование
class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  /// Получить список бронирований.
  Future<List<BookingModel>> getBookings({
    String? serviceCenterId,
    String? vehicleId,
    String? status,
  }) async {
    try {
      final response = await _apiClient.get(
        '/bookings',
        queryParameters: {
          if (serviceCenterId != null) 'service_center_id': serviceCenterId,
          if (vehicleId != null) 'vehicle_id': vehicleId,
          if (status != null) 'status': status,
        },
      );

      if (response.data is! List) {
        debugPrint('Bookings API: неожиданный формат ответа');
        return [];
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить бронирования: $e');
      return [];
    }
  }

  /// Создать новое бронирование
  Future<BookingModel?> createBooking({
    required String serviceCenterId,
    required String vehicleId,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/bookings',
        data: {
          'service_center_id': serviceCenterId,
          'vehicle_id': vehicleId,
          'scheduled_at': scheduledAt.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось создать бронирование: $e');
      return null;
    }
  }

  /// Получить бронирование по ID
  Future<BookingModel?> getBooking(String id) async {
    try {
      final response = await _apiClient.get('/bookings/$id');
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось загрузить бронирование: $e');
      return null;
    }
  }

  /// Обновить бронирование (изменить статус или заметки)
  Future<BookingModel?> updateBooking({
    required String id,
    String? status,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.put(
        '/bookings/$id',
        data: {
          if (status != null) 'status': status,
          if (notes != null) 'notes': notes,
        },
      );

      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось обновить бронирование: $e');
      return null;
    }
  }

  /// Отменить бронирование
  Future<bool> cancelBooking(String id) async {
    return await updateBooking(id: id, status: 'cancelled') != null;
  }

  /// Удалить бронирование
  Future<bool> deleteBooking(String id) async {
    try {
      await _apiClient.delete('/bookings/$id');
      return true;
    } catch (e) {
      debugPrint('Не удалось удалить бронирование: $e');
      return false;
    }
  }
}
