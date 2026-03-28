import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/booking_model.dart';
import '../mock/mock_data.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService(this._apiClient);

  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await _apiClient.get('/bookings');
      if (response.data is! List) {
        return MockData.mockBookings;
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map(BookingModel.fromJson).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load bookings: $e');
      return MockData.mockBookings;
    }
  }

  Future<BookingModel> createBooking({
    required String serviceName,
    required String address,
    required DateTime date,
    required String timeSlot,
    required double price,
  }) async {
    try {
      final response = await _apiClient.post(
        '/bookings',
        data: {
          'serviceName': serviceName,
          'address': address,
          'date': date.toIso8601String(),
          'timeSlot': timeSlot,
          'price': price,
        },
      );
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return BookingModel(
        id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
        serviceName: serviceName,
        address: address,
        date: date,
        timeSlot: timeSlot,
        status: 'upcoming',
        price: price,
      );
    }
  }

  Future<BookingModel> rescheduleBooking({
    required String id,
    required DateTime date,
    required String timeSlot,
  }) async {
    try {
      final response = await _apiClient.put(
        '/bookings/$id',
        data: {'date': date.toIso8601String(), 'timeSlot': timeSlot},
      );
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      final original = MockData.mockBookings.firstWhere(
        (item) => item.id == id,
      );
      return BookingModel(
        id: id,
        serviceName: original.serviceName,
        address: original.address,
        date: date,
        timeSlot: timeSlot,
        status: original.status,
        price: original.price,
      );
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _apiClient.delete('/bookings/$id');
    } catch (_) {}
  }
}
