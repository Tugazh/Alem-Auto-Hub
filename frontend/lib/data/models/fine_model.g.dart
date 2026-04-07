// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FineModel _$FineModelFromJson(Map<String, dynamic> json) => FineModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  vehicleId: json['vehicle_id'] as String?,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'KZT',
  article: json['article'] as String?,
  description: json['description'] as String,
  issuedAt: DateTime.parse(json['issued_at'] as String),
  paidAt: json['paid_at'] == null
      ? null
      : DateTime.parse(json['paid_at'] as String),
  status: json['status'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FineModelToJson(FineModel instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'vehicle_id': instance.vehicleId,
  'amount': instance.amount,
  'currency': instance.currency,
  'article': instance.article,
  'description': instance.description,
  'issued_at': instance.issuedAt.toIso8601String(),
  'paid_at': instance.paidAt?.toIso8601String(),
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
