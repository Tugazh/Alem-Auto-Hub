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
  final String serviceCenterId;
  final String vehicleId;
  final DateTime scheduledAt;
  final String? notes;

  const CreateBooking({
    required this.serviceCenterId,
    required this.vehicleId,
    required this.scheduledAt,
    this.notes,
  });

  @override
  List<Object?> get props => [serviceCenterId, vehicleId, scheduledAt, notes];
}

/// Update existing booking
class UpdateBooking extends BookingEvent {
  final String id;
  final String? status;
  final String? notes;

  const UpdateBooking({required this.id, this.status, this.notes});

  @override
  List<Object?> get props => [id, status, notes];
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
