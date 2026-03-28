import 'package:equatable/equatable.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/error/failures.dart';

/// Booking States
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookingInitial extends BookingState {
  const BookingInitial();
}

/// Loading bookings
class BookingLoading extends BookingState {
  final bool isRefreshing;

  const BookingLoading({this.isRefreshing = false});

  @override
  List<Object?> get props => [isRefreshing];
}

/// Bookings loaded successfully
class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  final List<BookingModel> filteredBookings;
  final String currentFilter; // 'all', 'upcoming', 'completed', 'cancelled'
  final BookingModel? selectedBooking;
  final bool isFromCache;

  const BookingLoaded({
    required this.bookings,
    required this.filteredBookings,
    this.currentFilter = 'all',
    this.selectedBooking,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [
    bookings,
    filteredBookings,
    currentFilter,
    selectedBooking,
    isFromCache,
  ];

  BookingLoaded copyWith({
    List<BookingModel>? bookings,
    List<BookingModel>? filteredBookings,
    String? currentFilter,
    BookingModel? selectedBooking,
    bool? isFromCache,
  }) {
    return BookingLoaded(
      bookings: bookings ?? this.bookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      currentFilter: currentFilter ?? this.currentFilter,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  /// Helper: Get upcoming bookings count
  int get upcomingCount => bookings.where((b) => b.status == 'upcoming').length;

  /// Helper: Get completed bookings count
  int get completedCount =>
      bookings.where((b) => b.status == 'completed').length;
}

/// Error loading bookings
class BookingError extends BookingState {
  final Failure failure;
  final List<BookingModel>? cachedBookings;

  const BookingError(this.failure, {this.cachedBookings});

  @override
  List<Object?> get props => [failure, cachedBookings];

  /// Get user-friendly error message
  String get message {
    if (failure is ServerFailure) {
      return 'Ошибка сервера. Попробуйте позже.';
    } else if (failure is NetworkFailure) {
      return cachedBookings != null
          ? 'Нет интернета. Показаны сохранённые данные.'
          : 'Нет подключения к интернету.';
    } else if (failure is ValidationFailure) {
      return 'Ошибка валидации данных.';
    } else if (failure is NotFoundFailure) {
      return 'Бронирование не найдено.';
    }
    return 'Произошла ошибка: ${failure.message}';
  }
}

/// Booking operation in progress (create/update/cancel)
class BookingOperationInProgress extends BookingState {
  final String operationType; // 'create', 'update', 'cancel'

  const BookingOperationInProgress(this.operationType);

  @override
  List<Object?> get props => [operationType];
}

/// Booking operation completed successfully
class BookingOperationSuccess extends BookingState {
  final String operationType; // 'create', 'update', 'cancel'
  final String message;

  const BookingOperationSuccess(this.operationType, this.message);

  @override
  List<Object?> get props => [operationType, message];
}
