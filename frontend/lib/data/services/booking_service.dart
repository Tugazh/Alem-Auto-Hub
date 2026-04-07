import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/booking_model.dart';

/// Booking Service для работы с /api/v1/bookings
///
/// Backend endpoints:
/// - POST /bookings - Создать бронирование
/// - GET /bookings - Список бронирований (с фильтрами)
/// - GET /bookings/:id - Получить бронирование
/// - PATCH /bookings/:id - Обновить бронирование (статус, заметки)
/// - DELETE /bookings/:id - Удалить бронирование
class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  /// Получить список бронирований
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
        debugPrint('⚠️ Bookings API: unexpected response format');
        return [];
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to load bookings: $e');
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
      debugPrint('❌ Failed to create booking: $e');
      return null;
    }
  }

  /// Получить бронирование по ID
  Future<BookingModel?> getBooking(String id) async {
    try {
      final response = await _apiClient.get('/bookings/$id');
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to load booking: $e');
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
      debugPrint('❌ Failed to update booking: $e');
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
      debugPrint('❌ Failed to delete booking: $e');
      return false;
    }
  }
}
