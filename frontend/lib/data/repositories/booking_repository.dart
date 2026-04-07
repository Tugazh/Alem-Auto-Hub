import '../../core/error/result.dart';
import '../../core/error/failures.dart';
import '../models/booking_model.dart';
import '../datasources/booking_remote_data_source.dart';
import '../datasources/booking_local_data_source.dart';
import '../../core/network/network_info.dart';

/// Repository for booking operations with offline-first strategy
abstract class BookingRepository {
  Future<Result<List<BookingModel>>> getBookings();
  Future<Result<List<BookingModel>>> refreshBookings();

  Future<Result<BookingModel>> createBooking({
    required String serviceCenterId,
    required String vehicleId,
    required DateTime scheduledAt,
    String? notes,
  });

  Future<Result<BookingModel>> updateBooking({
    required String id,
    String? status,
    String? notes,
  });

  Future<Result<void>> cancelBooking(String id);
}

/// Implementation of BookingRepository
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final BookingLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<BookingModel>>> getBookings() async {
    // Check network connectivity
    if (await networkInfo.isConnected) {
      try {
        // Try to fetch from remote
        final bookings = await remoteDataSource.getBookings();

        // Cache the result
        await localDataSource.cacheBookings(bookings);

        return Success(bookings);
      } catch (e) {
        // On error, fallback to cache
        final cachedBookings = await localDataSource.getCachedBookings();
        if (cachedBookings.isNotEmpty) {
          return Success(cachedBookings);
        }

        return ResultFailure(_mapExceptionToFailure(e));
      }
    } else {
      // No network, use cache
      final cachedBookings = await localDataSource.getCachedBookings();
      if (cachedBookings.isNotEmpty) {
        return Success(cachedBookings);
      }

      return const ResultFailure(
        NetworkFailure(message: 'Нет подключения к интернету'),
      );
    }
  }

  @override
  Future<Result<List<BookingModel>>> refreshBookings() async {
    try {
      // Force network fetch
      final bookings = await remoteDataSource.getBookings();

      // Update cache
      await localDataSource.cacheBookings(bookings);

      return Success(bookings);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<BookingModel>> createBooking({
    required String serviceCenterId,
    required String vehicleId,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    try {
      final booking = await remoteDataSource.createBooking(
        serviceCenterId: serviceCenterId,
        vehicleId: vehicleId,
        scheduledAt: scheduledAt,
        notes: notes,
      );

      if (booking == null) {
        return const ResultFailure(
          ServerFailure(message: 'Failed to create booking'),
        );
      }

      // Invalidate cache to force refresh
      await localDataSource.clearCache();

      return Success(booking);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<BookingModel>> updateBooking({
    required String id,
    String? status,
    String? notes,
  }) async {
    try {
      final booking = await remoteDataSource.updateBooking(
        id: id,
        status: status,
        notes: notes,
      );

      if (booking == null) {
        return const ResultFailure(
          ServerFailure(message: 'Failed to update booking'),
        );
      }

      // Invalidate cache
      await localDataSource.clearCache();

      return Success(booking);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> cancelBooking(String id) async {
    try {
      await remoteDataSource.cancelBooking(id);

      // Invalidate cache
      await localDataSource.clearCache();

      return const Success(null);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  /// Map exceptions to typed failures
  Failure _mapExceptionToFailure(Object e) {
    if (e.toString().contains('SocketException') ||
        e.toString().contains('NetworkException')) {
      return const NetworkFailure(message: 'Нет подключения к серверу');
    } else if (e.toString().contains('TimeoutException')) {
      return const TimeoutFailure(message: 'Превышено время ожидания');
    } else if (e.toString().contains('401')) {
      return const AuthFailure(message: 'Требуется авторизация');
    } else if (e.toString().contains('404')) {
      return const NotFoundFailure(message: 'Бронирование не найдено');
    } else if (e.toString().contains('500')) {
      return const ServerFailure(message: 'Ошибка сервера');
    }
    return UnknownFailure(message: e.toString());
  }
}
