import '../models/booking_model.dart';
import '../services/booking_service.dart';

/// Remote data source for bookings (API layer)
class BookingRemoteDataSource {
  final BookingService bookingService;

  BookingRemoteDataSource(this.bookingService);

  Future<List<BookingModel>> getBookings() async {
    return await bookingService.getBookings();
  }

  Future<BookingModel> createBooking({
    required String serviceName,
    required String address,
    required DateTime date,
    required String timeSlot,
    required double price,
  }) async {
    return await bookingService.createBooking(
      serviceName: serviceName,
      address: address,
      date: date,
      timeSlot: timeSlot,
      price: price,
    );
  }

  Future<BookingModel> updateBooking({
    required String id,
    required DateTime date,
    required String timeSlot,
  }) async {
    return await bookingService.rescheduleBooking(
      id: id,
      date: date,
      timeSlot: timeSlot,
    );
  }

  Future<void> cancelBooking(String id) async {
    await bookingService.cancelBooking(id);
  }
}
