// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaintenanceModel _$MaintenanceModelFromJson(Map<String, dynamic> json) =>
    MaintenanceModel(
      id: json['id'] as String,
      garageId: json['garageId'] as String,
      type: json['type'] as String,
      status: $enumDecode(_$MaintenanceStatusEnumMap, json['status']),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      actualCost: (json['actualCost'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      serviceProvider: json['serviceProvider'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MaintenanceModelToJson(MaintenanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'garageId': instance.garageId,
      'type': instance.type,
      'status': _$MaintenanceStatusEnumMap[instance.status]!,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'completedDate': instance.completedDate?.toIso8601String(),
      'estimatedCost': instance.estimatedCost,
      'actualCost': instance.actualCost,
      'notes': instance.notes,
      'serviceProvider': instance.serviceProvider,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$MaintenanceStatusEnumMap = {
  MaintenanceStatus.pending: 'pending',
  MaintenanceStatus.completed: 'completed',
  MaintenanceStatus.overdue: 'overdue',
  MaintenanceStatus.cancelled: 'cancelled',
};
