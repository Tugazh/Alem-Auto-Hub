import 'package:json_annotation/json_annotation.dart';

part 'maintenance_model.g.dart';

/// Maintenance record model для /api/v1/maintenance
@JsonSerializable()
class MaintenanceModel {
  final String id;
  final String garageId;
  final String type;
  final MaintenanceStatus status;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final double? estimatedCost;
  final double? actualCost;
  final String? notes;
  final String? serviceProvider;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MaintenanceModel({
    required this.id,
    required this.garageId,
    required this.type,
    required this.status,
    required this.scheduledDate,
    this.completedDate,
    this.estimatedCost,
    this.actualCost,
    this.notes,
    this.serviceProvider,
    this.createdAt,
    this.updatedAt,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$MaintenanceModelToJson(this);
}

enum MaintenanceStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
}

enum MaintenanceType {
  @JsonValue('oil_change')
  oilChange,
  @JsonValue('tire_rotation')
  tireRotation,
  @JsonValue('brake_inspection')
  brakeInspection,
  @JsonValue('engine_check')
  engineCheck,
  @JsonValue('general_service')
  generalService,
  @JsonValue('other')
  other,
}
