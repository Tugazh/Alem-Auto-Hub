import 'package:json_annotation/json_annotation.dart';

part 'warehouse_part_model.g.dart';

/// Warehouse Part model для /api/v1/warehouse/parts
/// Backend: id, name, part_number, category, manufacturer, description, price, currency, quantity_in_stock, min_stock_level
@JsonSerializable()
class WarehousePartModel {
  final String id;
  final String name;

  @JsonKey(name: 'part_number')
  final String partNumber;

  final String
  category; // engine, transmission, suspension, brakes, electrical, body, accessories, other
  final String? manufacturer;
  final String? description;
  final double? price;
  final String currency;

  @JsonKey(name: 'quantity_in_stock')
  final int quantityInStock;

  @JsonKey(name: 'min_stock_level')
  final int minStockLevel;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const WarehousePartModel({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.category,
    this.manufacturer,
    this.description,
    this.price,
    this.currency = 'KZT',
    required this.quantityInStock,
    this.minStockLevel = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory WarehousePartModel.fromJson(Map<String, dynamic> json) =>
      _$WarehousePartModelFromJson(json);

  Map<String, dynamic> toJson() => _$WarehousePartModelToJson(this);

  // Helpers
  bool get inStock => quantityInStock > 0;
  bool get needsRestock => quantityInStock <= minStockLevel;
  String get priceFormatted =>
      price != null ? '${price!.toStringAsFixed(0)} ₸' : 'Уточнить';
}

/// Категории запчастей (соответствуют backend enum)
enum PartCategory {
  @JsonValue('engine')
  engine,

  @JsonValue('transmission')
  transmission,

  @JsonValue('suspension')
  suspension,

  @JsonValue('brakes')
  brakes,

  @JsonValue('electrical')
  electrical,

  @JsonValue('body')
  body,

  @JsonValue('accessories')
  accessories,

  @JsonValue('other')
  other,
}

extension PartCategoryExtension on PartCategory {
  String get displayName {
    switch (this) {
      case PartCategory.engine:
        return 'Двигатель';
      case PartCategory.transmission:
        return 'Трансмиссия';
      case PartCategory.suspension:
        return 'Подвеска';
      case PartCategory.brakes:
        return 'Тормоза';
      case PartCategory.electrical:
        return 'Электрика';
      case PartCategory.body:
        return 'Кузов';
      case PartCategory.accessories:
        return 'Аксессуары';
      case PartCategory.other:
        return 'Прочее';
    }
  }
}
