import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../data/repositories/garage_repository.dart';
import '../../../core/error/result.dart';
import 'garage_event.dart';
import 'garage_state.dart';

/// BLoC for managing garage (vehicle list) feature
/// Implements offline-first architecture with automatic fallback to cache
class GarageBloc extends Bloc<GarageEvent, GarageState> {
  final GarageRepository _repository;
  final Logger _logger;

  GarageBloc({required GarageRepository repository})
    : _repository = repository,
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 3,
          lineLength: 80,
          colors: true,
          printEmojis: true,
        ),
      ),
      super(const GarageInitial()) {
    // Register event handlers
    on<LoadVehicles>(_onLoadVehicles);
    on<RefreshVehicles>(_onRefreshVehicles);
    on<CreateVehicle>(_onCreateVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<SelectVehicle>(_onSelectVehicle);
  }

  /// Load vehicles from repository (cache-first strategy)
  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<GarageState> emit,
  ) async {
    _logger.i('Loading vehicles...');
    emit(const GarageLoading());

    final result = await _repository.getVehicles();

    result.when(
      success: (vehicles) {
        _logger.i('Loaded ${vehicles.length} vehicles');
        emit(
          GarageLoaded(
            vehicles: vehicles,
            isFromCache: _repository.isDataFromCache,
          ),
        );
      },
      failure: (failure) {
        _logger.e('Failed to load vehicles: ${failure.message}');
        emit(GarageError(failure: failure));
      },
    );
  }

  /// Refresh vehicles from API (force network call)
  Future<void> _onRefreshVehicles(
    RefreshVehicles event,
    Emitter<GarageState> emit,
  ) async {
    _logger.i('Refreshing vehicles from network...');

    // Keep existing data while refreshing
    final currentState = state;
    if (currentState is GarageLoaded) {
      emit(const GarageLoading(isRefreshing: true));
    } else {
      emit(const GarageLoading());
    }

    final result = await _repository.refreshVehicles();

    result.when(
      success: (vehicles) {
        _logger.i('Refreshed ${vehicles.length} vehicles');
        emit(
          GarageLoaded(
            vehicles: vehicles,
            selectedVehicle: currentState is GarageLoaded
                ? currentState.selectedVehicle
                : null,
          ),
        );
      },
      failure: (failure) {
        _logger.e('Failed to refresh vehicles: ${failure.message}');

        // Show error but keep cached data if available
        if (currentState is GarageLoaded) {
          emit(
            GarageError(
              failure: failure,
              cachedVehicles: currentState.vehicles,
            ),
          );
        } else {
          emit(GarageError(failure: failure));
        }
      },
    );
  }

  /// Create new vehicle
  Future<void> _onCreateVehicle(
    CreateVehicle event,
    Emitter<GarageState> emit,
  ) async {
    _logger.i('Creating vehicle: ${event.vehicle.name}');
    emit(const GarageOperationInProgress(operationType: 'create'));

    final result = await _repository.createVehicle(event.vehicle);

    await result.when(
      success: (vehicle) async {
        _logger.i('Vehicle created successfully: ${vehicle.id}');
        emit(
          const GarageOperationSuccess(
            operationType: 'create',
            message: 'Автомобиль успешно добавлен',
          ),
        );

        // Reload vehicles to show the new one
        add(const LoadVehicles());
      },
      failure: (failure) async {
        _logger.e('Failed to create vehicle: ${failure.message}');
        emit(GarageError(failure: failure));

        // Return to previous state
        add(const LoadVehicles());
      },
    );
  }

  /// Update existing vehicle
  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<GarageState> emit,
  ) async {
    final vehicleId = event.vehicle.id;
    _logger.i('Updating vehicle: $vehicleId');
    emit(
      GarageOperationInProgress(operationType: 'update', vehicleId: vehicleId),
    );

    final result = await _repository.updateVehicle(event.vehicle);

    await result.when(
      success: (vehicle) async {
        _logger.i('Vehicle updated successfully: ${vehicle.id}');
        emit(
          const GarageOperationSuccess(
            operationType: 'update',
            message: 'Автомобиль успешно обновлен',
          ),
        );

        // Reload vehicles
        add(const LoadVehicles());
      },
      failure: (failure) async {
        _logger.e('Failed to update vehicle: ${failure.message}');
        emit(GarageError(failure: failure));

        // Return to previous state
        add(const LoadVehicles());
      },
    );
  }

  /// Delete vehicle
  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<GarageState> emit,
  ) async {
    _logger.i('Deleting vehicle: ${event.vehicleId}');
    emit(
      GarageOperationInProgress(
        operationType: 'delete',
        vehicleId: event.vehicleId,
      ),
    );

    final result = await _repository.deleteVehicle(event.vehicleId);

    await result.when(
      success: (_) async {
        _logger.i('Vehicle deleted successfully: ${event.vehicleId}');
        emit(
          const GarageOperationSuccess(
            operationType: 'delete',
            message: 'Автомобиль успешно удален',
          ),
        );

        // Reload vehicles
        add(const LoadVehicles());
      },
      failure: (failure) async {
        _logger.e('Failed to delete vehicle: ${failure.message}');
        emit(GarageError(failure: failure));

        // Return to previous state
        add(const LoadVehicles());
      },
    );
  }

  /// Select vehicle for details view
  Future<void> _onSelectVehicle(
    SelectVehicle event,
    Emitter<GarageState> emit,
  ) async {
    final currentState = state;
    if (currentState is GarageLoaded) {
      emit(currentState.copyWith(selectedVehicle: () => event.vehicle));
    }
  }
}
