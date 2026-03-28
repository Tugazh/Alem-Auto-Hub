import 'package:equatable/equatable.dart';

/// Booking Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Load all bookings for current user
class LoadBookings extends BookingEvent {
  const LoadBookings();
}

/// Refresh bookings from server
class RefreshBookings extends BookingEvent {
  const RefreshBookings();
}

/// Create new booking
class CreateBooking extends BookingEvent {
  final String serviceName;
  final String address;
  final DateTime date;
  final String timeSlot;
  final double price;

  const CreateBooking({
    required this.serviceName,
    required this.address,
    required this.date,
    required this.timeSlot,
    required this.price,
  });

  @override
  List<Object?> get props => [serviceName, address, date, timeSlot, price];
}

/// Update existing booking
class UpdateBooking extends BookingEvent {
  final String id;
  final DateTime date;
  final String timeSlot;

  const UpdateBooking({
    required this.id,
    required this.date,
    required this.timeSlot,
  });

  @override
  List<Object?> get props => [id, date, timeSlot];
}

/// Cancel booking
class CancelBooking extends BookingEvent {
  final String id;

  const CancelBooking(this.id);

  @override
  List<Object?> get props => [id];
}

/// Select booking for details
class SelectBooking extends BookingEvent {
  final String bookingId;

  const SelectBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Filter bookings by status
class FilterBookingsByStatus extends BookingEvent {
  final String status; // 'all', 'upcoming', 'completed', 'cancelled'

  const FilterBookingsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}
