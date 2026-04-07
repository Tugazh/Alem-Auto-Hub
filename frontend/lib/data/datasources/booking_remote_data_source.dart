import '../models/booking_model.dart';
import '../services/booking_service.dart';

/// Remote data source for bookings (API layer)
class BookingRemoteDataSource {
  final BookingService bookingService;

  BookingRemoteDataSource(this.bookingService);

  /// Получить список бронирований
  Future<List<BookingModel>> getBookings({
    String? serviceCenterId,
    String? vehicleId,
    String? status,
  }) async {
    return await bookingService.getBookings(
      serviceCenterId: serviceCenterId,
      vehicleId: vehicleId,
      status: status,
    );
  }

  /// Создать новое бронирование
  Future<BookingModel?> createBooking({
    required String serviceCenterId,
    required String vehicleId,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    return await bookingService.createBooking(
      serviceCenterId: serviceCenterId,
      vehicleId: vehicleId,
      scheduledAt: scheduledAt,
      notes: notes,
    );
  }

  /// Получить конкретное бронирование
  Future<BookingModel?> getBooking(String id) async {
    return await bookingService.getBooking(id);
  }

  /// Обновить бронирование (статус или заметки)
  Future<BookingModel?> updateBooking({
    required String id,
    String? status,
    String? notes,
  }) async {
    return await bookingService.updateBooking(
      id: id,
      status: status,
      notes: notes,
    );
  }

  /// Отменить бронирование (установить status = 'cancelled')
  Future<bool> cancelBooking(String id) async {
    return await bookingService.cancelBooking(id);
  }

  /// Удалить бронирование
  Future<void> deleteBooking(String id) async {
    await bookingService.deleteBooking(id);
  }
}
