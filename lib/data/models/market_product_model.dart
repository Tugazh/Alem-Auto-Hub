import 'package:json_annotation/json_annotation.dart';

part 'market_product_model.g.dart';

/// Market product model для /api/v1/market
@JsonSerializable()
class MarketProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String sellerId;
  final List<String> images;
  final bool available;
  final int viewCount;
  final int favoriteCount;
  final String? condition; // 'new', 'used', 'refurbished'
  final String? brand;
  final String? location;
  final Map<String, dynamic>? specifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MarketProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.sellerId,
    this.images = const [],
    this.available = true,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.condition,
    this.brand,
    this.location,
    this.specifications,
    this.createdAt,
    this.updatedAt,
  });

  factory MarketProductModel.fromJson(Map<String, dynamic> json) =>
      _$MarketProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketProductModelToJson(this);
}

/// Market category
enum MarketCategory {
  @JsonValue('parts')
  parts,
  @JsonValue('accessories')
  accessories,
  @JsonValue('tools')
  tools,
  @JsonValue('services')
  services,
  @JsonValue('other')
  other,
}
