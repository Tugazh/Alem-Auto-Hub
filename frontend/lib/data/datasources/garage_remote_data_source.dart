import '../models/car_model.dart';
import '../../core/di/service_locator.dart';
import '../services/garage_service.dart';

/// Remote data source for garage/vehicle operations
/// Communicates with backend API
abstract class GarageRemoteDataSource {
  Future<List<CarModel>> getVehicles();
  Future<CarModel> createVehicle(CarModel vehicle);
  Future<CarModel> updateVehicle(CarModel vehicle);
  Future<void> deleteVehicle(String vehicleId);
}

class GarageRemoteDataSourceImpl implements GarageRemoteDataSource {
  final GarageService _garageService;

  GarageRemoteDataSourceImpl({GarageService? garageService})
    : _garageService = garageService ?? ServiceLocator().garageService;

  @override
  Future<List<CarModel>> getVehicles() async {
    return await _garageService.getGarages();
  }

  @override
  Future<CarModel> createVehicle(CarModel vehicle) async {
    return await _garageService.createGarage(
      name: vehicle.name,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      vin: vehicle.vin,
      plateNumber: vehicle.plateNumber,
      mileage: vehicle.mileage,
    );
  }

  @override
  Future<CarModel> updateVehicle(CarModel vehicle) async {
    return await _garageService.updateGarage(
      vehicle.id,
      name: vehicle.name,
      mileage: vehicle.mileage,
      notes: vehicle.notes,
    );
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await _garageService.deleteGarage(vehicleId);
  }
}
