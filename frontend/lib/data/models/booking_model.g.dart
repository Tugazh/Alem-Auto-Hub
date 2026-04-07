// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String,
  serviceCenterId: json['service_center_id'] as String,
  vehicleId: json['vehicle_id'] as String,
  userId: json['user_id'] as String,
  scheduledAt: DateTime.parse(json['scheduled_at'] as String),
  status: json['status'] as String,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'service_center_id': instance.serviceCenterId,
      'vehicle_id': instance.vehicleId,
      'user_id': instance.userId,
      'scheduled_at': instance.scheduledAt.toIso8601String(),
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
