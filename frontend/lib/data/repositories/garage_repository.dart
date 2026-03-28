import '../../../core/error/result.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../models/car_model.dart';
import '../datasources/garage_local_data_source.dart';
import '../datasources/garage_remote_data_source.dart';
import 'package:logger/logger.dart';

/// Repository for garage/vehicle management
/// Implements cache-first strategy with automatic fallback
abstract class GarageRepository {
  Future<Result<List<CarModel>>> getVehicles();
  Future<Result<List<CarModel>>> refreshVehicles();
  Future<Result<CarModel>> createVehicle(CarModel vehicle);
  Future<Result<CarModel>> updateVehicle(CarModel vehicle);
  Future<Result<void>> deleteVehicle(String vehicleId);
  bool get isDataFromCache;
}

class GarageRepositoryImpl implements GarageRepository {
  final GarageRemoteDataSource _remoteDataSource;
  final GarageLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  bool _isFromCache = false;

  GarageRepositoryImpl({
    required GarageRemoteDataSource remoteDataSource,
    required GarageLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _logger = Logger(
         printer: PrettyPrinter(
           methodCount: 0,
           errorMethodCount: 3,
           lineLength: 80,
           colors: true,
           printEmojis: true,
         ),
       );

  @override
  bool get isDataFromCache => _isFromCache;

  @override
  Future<Result<List<CarModel>>> getVehicles() async {
    try {
      _logger.i('Getting vehicles...');

      // Check network connectivity
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        // Try to fetch from network
        try {
          _logger.d('Fetching vehicles from network');
          final vehicles = await _remoteDataSource.getVehicles();

          // Cache the result
          await _localDataSource.cacheVehicles(vehicles);
          _isFromCache = false;

          return Success(vehicles);
        } catch (e) {
          _logger.w('Network fetch failed, falling back to cache: $e');

          // Network failed, try cache
          return _getCachedVehicles();
        }
      } else {
        _logger.i('No network, loading from cache');
        return _getCachedVehicles();
      }
    } catch (e) {
      _logger.e('Failed to get vehicles: $e');
      return ResultFailure(
        UnknownFailure(message: 'Не удалось загрузить автомобили: $e'),
      );
    }
  }

  @override
  Future<Result<List<CarModel>>> refreshVehicles() async {
    try {
      _logger.i('Refreshing vehicles from network...');

      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        return const ResultFailure(NetworkFailure());
      }

      final vehicles = await _remoteDataSource.getVehicles();

      // Update cache
      await _localDataSource.cacheVehicles(vehicles);
      _isFromCache = false;

      return Success(vehicles);
    } catch (e) {
      _logger.e('Failed to refresh vehicles: $e');
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<CarModel>> createVehicle(CarModel vehicle) async {
    try {
      _logger.i('Creating vehicle...');

      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        return const ResultFailure(
          NetworkFailure(
            message:
                'Требуется подключение к интернету для создания автомобиля',
          ),
        );
      }

      final createdVehicle = await _remoteDataSource.createVehicle(vehicle);

      // Invalidate cache to force refresh
      await _localDataSource.clearCache();

      return Success(createdVehicle);
    } catch (e) {
      _logger.e('Failed to create vehicle: $e');
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<CarModel>> updateVehicle(CarModel vehicle) async {
    try {
      _logger.i('Updating vehicle: ${vehicle.id}');

      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        return const ResultFailure(
          NetworkFailure(
            message:
                'Требуется подключение к интернету для обновления автомобиля',
          ),
        );
      }

      final updatedVehicle = await _remoteDataSource.updateVehicle(vehicle);

      // Invalidate cache
      await _localDataSource.clearCache();

      return Success(updatedVehicle);
    } catch (e) {
      _logger.e('Failed to update vehicle: $e');
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteVehicle(String vehicleId) async {
    try {
      _logger.i('Deleting vehicle: $vehicleId');

      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        return const ResultFailure(
          NetworkFailure(
            message:
                'Требуется подключение к интернету для удаления автомобиля',
          ),
        );
      }

      await _remoteDataSource.deleteVehicle(vehicleId);

      // Invalidate cache
      await _localDataSource.clearCache();

      return const Success(null);
    } catch (e) {
      _logger.e('Failed to delete vehicle: $e');
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  /// Get vehicles from cache with proper error handling
  Future<Result<List<CarModel>>> _getCachedVehicles() async {
    try {
      final cachedVehicles = await _localDataSource.getCachedVehicles();

      if (cachedVehicles != null && cachedVehicles.isNotEmpty) {
        _logger.i('Loaded ${cachedVehicles.length} vehicles from cache');
        _isFromCache = true;
        return Success(cachedVehicles);
      } else {
        _logger.w('No cached vehicles found');
        return const ResultFailure(
          CacheFailure(message: 'Нет сохраненных данных'),
        );
      }
    } catch (e) {
      _logger.e('Cache read failed: $e');
      return ResultFailure(CacheFailure(message: 'Ошибка чтения кэша: $e'));
    }
  }

  /// Map exceptions to typed failures
  Failure _mapExceptionToFailure(dynamic exception) {
    final errorString = exception.toString().toLowerCase();

    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return const NetworkFailure();
    }

    if (errorString.contains('timeout')) {
      return const TimeoutFailure();
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return const AuthFailure();
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return const AuthorizationFailure();
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return const NotFoundFailure();
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return ServerFailure(message: exception.toString());
    }

    if (errorString.contains('400') || errorString.contains('bad request')) {
      return ClientFailure(message: exception.toString());
    }

    return UnknownFailure(message: exception.toString());
  }
}
