import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

/// Booking model для /api/v1/bookings
/// Backend: id, service_center_id, vehicle_id, user_id, scheduled_at, status, notes
@JsonSerializable()
class BookingModel {
  final String id;

  @JsonKey(name: 'service_center_id')
  final String serviceCenterId;

  @JsonKey(name: 'vehicle_id')
  final String vehicleId;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'scheduled_at')
  final DateTime scheduledAt;

  final String status; // scheduled, completed, cancelled, no_show
  final String? notes;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Дополнительные поля для UI
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? serviceName;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? address;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? price;

  const BookingModel({
    required this.id,
    required this.serviceCenterId,
    required this.vehicleId,
    required this.userId,
    required this.scheduledAt,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.serviceName,
    this.address,
    this.price,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  // Helpers
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  String get timeSlot =>
      '${scheduledAt.hour}:${scheduledAt.minute.toString().padLeft(2, '0')}';
}
