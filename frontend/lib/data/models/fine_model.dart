import 'package:json_annotation/json_annotation.dart';

part 'fine_model.g.dart';

/// Fine model для /api/v1/fines
/// Backend: id, user_id, vehicle_id, amount, currency, article, description, issued_at, paid_at, status
@JsonSerializable()
class FineModel {
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'vehicle_id')
  final String? vehicleId;

  final double amount;
  final String currency;
  final String? article; // Статья КоАП
  final String description;

  @JsonKey(name: 'issued_at')
  final DateTime issuedAt;

  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  final String status; // pending, paid, disputed

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Дополнительные поля для UI
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? location;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? photoUrl;

  const FineModel({
    required this.id,
    required this.userId,
    this.vehicleId,
    required this.amount,
    this.currency = 'KZT',
    this.article,
    required this.description,
    required this.issuedAt,
    this.paidAt,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.photoUrl,
  });

  factory FineModel.fromJson(Map<String, dynamic> json) =>
      _$FineModelFromJson(json);

  Map<String, dynamic> toJson() => _$FineModelToJson(this);

  // Helpers
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isDisputed => status == 'disputed';
  String get amountFormatted => '${amount.toStringAsFixed(0)} ₸';
  String get title => article ?? 'Штраф';
}
