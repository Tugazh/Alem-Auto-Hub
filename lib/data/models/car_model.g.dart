// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarModel _$CarModelFromJson(Map<String, dynamic> json) => CarModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  make: json['make'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  vin: json['vin'] as String?,
  plateNumber: json['plateNumber'] as String?,
  color: json['color'] as String?,
  transmission: json['transmission'] as String?,
  drivetrain: json['drivetrain'] as String?,
  fuelType: json['fuelType'] as String?,
  engineType: json['engineType'] as String?,
  mileage: (json['mileage'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  model3dUrl: json['model3dUrl'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CarModelToJson(CarModel instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'make': instance.make,
  'model': instance.model,
  'year': instance.year,
  'vin': instance.vin,
  'plateNumber': instance.plateNumber,
  'color': instance.color,
  'transmission': instance.transmission,
  'drivetrain': instance.drivetrain,
  'fuelType': instance.fuelType,
  'engineType': instance.engineType,
  'mileage': instance.mileage,
  'imageUrl': instance.imageUrl,
  'model3dUrl': instance.model3dUrl,
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
