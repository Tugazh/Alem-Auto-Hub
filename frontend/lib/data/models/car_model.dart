import 'package:json_annotation/json_annotation.dart';

part 'car_model.g.dart';

/// Car/Garage model соответствует backend /api/v1/garage
@JsonSerializable()
class CarModel {
  final String id;
  final String userId;
  final String name;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? plateNumber;
  final String? color;
  final String? transmission;
  final String? drivetrain;
  final String? fuelType;
  final String? engineType;
  final int? mileage;
  final String? imageUrl;
  final String? model3dUrl;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CarModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.plateNumber,
    this.color,
    this.transmission,
    this.drivetrain,
    this.fuelType,
    this.engineType,
    this.mileage,
    this.imageUrl,
    this.model3dUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) =>
      _$CarModelFromJson(json);

  Map<String, dynamic> toJson() => _$CarModelToJson(this);

  CarModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? plateNumber,
    String? color,
    String? transmission,
    String? drivetrain,
    String? fuelType,
    String? engineType,
    int? mileage,
    String? imageUrl,
    String? model3dUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      transmission: transmission ?? this.transmission,
      drivetrain: drivetrain ?? this.drivetrain,
      fuelType: fuelType ?? this.fuelType,
      engineType: engineType ?? this.engineType,
      mileage: mileage ?? this.mileage,
      imageUrl: imageUrl ?? this.imageUrl,
      model3dUrl: model3dUrl ?? this.model3dUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
