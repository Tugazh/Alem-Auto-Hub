import 'package:equatable/equatable.dart';
import '../../../data/models/car_model.dart';

/// Base class for all Garage events
sealed class GarageEvent extends Equatable {
  const GarageEvent();

  @override
  List<Object?> get props => [];
}

/// Load all vehicles for current user
class LoadVehicles extends GarageEvent {
  const LoadVehicles();
}

/// Refresh vehicles (force reload from API)
class RefreshVehicles extends GarageEvent {
  const RefreshVehicles();
}

/// Create new vehicle
class CreateVehicle extends GarageEvent {
  final CarModel vehicle;

  const CreateVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

/// Update existing vehicle
class UpdateVehicle extends GarageEvent {
  final CarModel vehicle;

  const UpdateVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

/// Delete vehicle
class DeleteVehicle extends GarageEvent {
  final String vehicleId;

  const DeleteVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

/// Select vehicle for details view
class SelectVehicle extends GarageEvent {
  final CarModel? vehicle;

  const SelectVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}
