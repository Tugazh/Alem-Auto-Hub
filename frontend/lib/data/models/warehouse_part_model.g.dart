// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_part_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarehousePartModel _$WarehousePartModelFromJson(Map<String, dynamic> json) =>
    WarehousePartModel(
      id: json['id'] as String,
      name: json['name'] as String,
      partNumber: json['part_number'] as String,
      category: json['category'] as String,
      manufacturer: json['manufacturer'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'KZT',
      quantityInStock: (json['quantity_in_stock'] as num).toInt(),
      minStockLevel: (json['min_stock_level'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WarehousePartModelToJson(WarehousePartModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'part_number': instance.partNumber,
      'category': instance.category,
      'manufacturer': instance.manufacturer,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'quantity_in_stock': instance.quantityInStock,
      'min_stock_level': instance.minStockLevel,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
