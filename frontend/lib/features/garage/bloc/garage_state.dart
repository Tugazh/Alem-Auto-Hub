import 'package:equatable/equatable.dart';
import '../../../data/models/car_model.dart';
import '../../../core/error/failures.dart';

/// Base class for all Garage states
sealed class GarageState extends Equatable {
  const GarageState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class GarageInitial extends GarageState {
  const GarageInitial();
}

/// Loading vehicles from API or cache
class GarageLoading extends GarageState {
  final bool isRefreshing;

  const GarageLoading({this.isRefreshing = false});

  @override
  List<Object?> get props => [isRefreshing];
}

/// Vehicles loaded successfully
class GarageLoaded extends GarageState {
  final List<CarModel> vehicles;
  final CarModel? selectedVehicle;
  final bool isFromCache;

  const GarageLoaded({
    required this.vehicles,
    this.selectedVehicle,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [vehicles, selectedVehicle, isFromCache];

  /// Create copy with updated fields
  GarageLoaded copyWith({
    List<CarModel>? vehicles,
    CarModel? Function()? selectedVehicle,
    bool? isFromCache,
  }) {
    return GarageLoaded(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle != null
          ? selectedVehicle()
          : this.selectedVehicle,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// Error occurred while loading/modifying vehicles
class GarageError extends GarageState {
  final Failure failure;
  final List<CarModel>? cachedVehicles;

  const GarageError({required this.failure, this.cachedVehicles});

  @override
  List<Object?> get props => [failure, cachedVehicles];

  /// Get user-friendly error message
  String get message {
    return switch (failure) {
      NetworkFailure() => 'Нет подключения к интернету',
      ServerFailure() => 'Ошибка сервера. Попробуйте позже',
      AuthFailure() => 'Требуется авторизация',
      NotFoundFailure() => 'Данные не найдены',
      TimeoutFailure() => 'Превышено время ожидания',
      _ => failure.message,
    };
  }
}

/// Operation in progress (create/update/delete)
class GarageOperationInProgress extends GarageState {
  final String operationType; // 'create', 'update', 'delete'
  final String? vehicleId;

  const GarageOperationInProgress({
    required this.operationType,
    this.vehicleId,
  });

  @override
  List<Object?> get props => [operationType, vehicleId];
}

/// Operation completed successfully
class GarageOperationSuccess extends GarageState {
  final String operationType;
  final String message;

  const GarageOperationSuccess({
    required this.operationType,
    required this.message,
  });

  @override
  List<Object?> get props => [operationType, message];
}
