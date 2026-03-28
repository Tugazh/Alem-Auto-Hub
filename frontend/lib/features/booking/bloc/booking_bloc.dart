import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/error/result.dart';

/// BLoC for managing bookings
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository repository;
  final Logger _logger = Logger();

  BookingBloc(this.repository) : super(const BookingInitial()) {
    on<LoadBookings>(_onLoadBookings);
    on<RefreshBookings>(_onRefreshBookings);
    on<CreateBooking>(_onCreateBooking);
    on<UpdateBooking>(_onUpdateBooking);
    on<CancelBooking>(_onCancelBooking);
    on<SelectBooking>(_onSelectBooking);
    on<FilterBookingsByStatus>(_onFilterBookingsByStatus);
  }

  /// Load bookings (cache-first strategy)
  Future<void> _onLoadBookings(
    LoadBookings event,
    Emitter<BookingState> emit,
  ) async {
    _logger.i('📥 Loading bookings...');
    emit(const BookingLoading());

    final result = await repository.getBookings();

    result.fold(
      (failure) {
        _logger.e('❌ Failed to load bookings: ${failure.message}');
        emit(BookingError(failure));
      },
      (bookings) {
        _logger.i('✅ Loaded ${bookings.length} bookings');
        emit(
          BookingLoaded(
            bookings: bookings,
            filteredBookings: bookings,
            isFromCache: result is Success,
          ),
        );
      },
    );
  }

  /// Refresh bookings (force network)
  Future<void> _onRefreshBookings(
    RefreshBookings event,
    Emitter<BookingState> emit,
  ) async {
    _logger.i('🔄 Refreshing bookings...');

    // Show loading indicator while keeping current data
    if (state is BookingLoaded) {
      emit(const BookingLoading(isRefreshing: true));
    } else {
      emit(const BookingLoading());
    }

    final result = await repository.refreshBookings();

    result.fold(
      (failure) {
        _logger.e('❌ Failed to refresh: ${failure.message}');

        // Try to show cached data on failure
        if (state is BookingLoaded) {
          final currentState = state as BookingLoaded;
          emit(BookingError(failure, cachedBookings: currentState.bookings));
        } else {
          emit(BookingError(failure));
        }
      },
      (bookings) {
        _logger.i('✅ Refreshed ${bookings.length} bookings');
        emit(
          BookingLoaded(
            bookings: bookings,
            filteredBookings: _applyCurrentFilter(bookings),
          ),
        );
      },
    );
  }

  /// Create new booking
  Future<void> _onCreateBooking(
    CreateBooking event,
    Emitter<BookingState> emit,
  ) async {
    _logger.i('➕ Creating booking: ${event.serviceName}');
    emit(const BookingOperationInProgress('create'));

    final result = await repository.createBooking(
      serviceName: event.serviceName,
      address: event.address,
      date: event.date,
      timeSlot: event.timeSlot,
      price: event.price,
    );

    result.fold(
      (failure) {
        _logger.e('❌ Failed to create booking: ${failure.message}');
        emit(BookingError(failure));

        // Restore previous state if available
        if (state is BookingLoaded) {
          final prevState = state as BookingLoaded;
          emit(prevState);
        }
      },
      (booking) {
        _logger.i('✅ Booking created: ${booking.id}');
        emit(const BookingOperationSuccess('create', 'Бронирование создано'));

        // Reload bookings
        add(const LoadBookings());
      },
    );
  }

  /// Update existing booking
  Future<void> _onUpdateBooking(
    UpdateBooking event,
    Emitter<BookingState> emit,
  ) async {
    _logger.i('✏️ Updating booking: ${event.id}');
    emit(const BookingOperationInProgress('update'));

    final result = await repository.updateBooking(
      id: event.id,
      date: event.date,
      timeSlot: event.timeSlot,
    );

    result.fold(
      (failure) {
        _logger.e('❌ Failed to update booking: ${failure.message}');
        emit(BookingError(failure));
      },
      (booking) {
        _logger.i('✅ Booking updated: ${booking.id}');
        emit(const BookingOperationSuccess('update', 'Бронирование обновлено'));

        // Reload bookings
        add(const LoadBookings());
      },
    );
  }

  /// Cancel booking
  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    _logger.i('❌ Cancelling booking: ${event.id}');
    emit(const BookingOperationInProgress('cancel'));

    final result = await repository.cancelBooking(event.id);

    result.fold(
      (failure) {
        _logger.e('❌ Failed to cancel booking: ${failure.message}');
        emit(BookingError(failure));
      },
      (_) {
        _logger.i('✅ Booking cancelled: ${event.id}');
        emit(const BookingOperationSuccess('cancel', 'Бронирование отменено'));

        // Reload bookings
        add(const LoadBookings());
      },
    );
  }

  /// Select booking for details view
  Future<void> _onSelectBooking(
    SelectBooking event,
    Emitter<BookingState> emit,
  ) async {
    if (state is BookingLoaded) {
      final currentState = state as BookingLoaded;
      final selected = currentState.bookings.firstWhere(
        (b) => b.id == event.bookingId,
        orElse: () => currentState.bookings.first,
      );

      emit(currentState.copyWith(selectedBooking: selected));
      _logger.i('📌 Selected booking: ${selected.id}');
    }
  }

  /// Filter bookings by status
  Future<void> _onFilterBookingsByStatus(
    FilterBookingsByStatus event,
    Emitter<BookingState> emit,
  ) async {
    if (state is BookingLoaded) {
      final currentState = state as BookingLoaded;
      final filtered = _filterBookings(currentState.bookings, event.status);

      emit(
        currentState.copyWith(
          filteredBookings: filtered,
          currentFilter: event.status,
        ),
      );

      _logger.i(
        '🔍 Filtered bookings: ${event.status} (${filtered.length} items)',
      );
    }
  }

  /// Helper: Apply current filter to bookings
  List<BookingModel> _applyCurrentFilter(List<BookingModel> bookings) {
    if (state is BookingLoaded) {
      final currentState = state as BookingLoaded;
      return _filterBookings(bookings, currentState.currentFilter);
    }
    return bookings;
  }

  /// Helper: Filter bookings by status
  List<BookingModel> _filterBookings(
    List<BookingModel> bookings,
    String filter,
  ) {
    if (filter == 'all') return bookings;
    return bookings.where((b) => b.status == filter).toList();
  }
}
