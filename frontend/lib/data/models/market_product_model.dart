import 'package:json_annotation/json_annotation.dart';

part 'market_product_model.g.dart';

/// Market product model для /api/v1/market
/// Backend структура: id, user_id, kind, title, description, category, price, currency, available
@JsonSerializable()
class MarketProductModel {
  final String id;

  @JsonKey(name: 'user_id')
  final String userId;

  final String kind; // 'product', 'service', 'ad'
  final String title;
  final String description;
  final double price;
  final String category;
  final String currency;
  final bool available;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Дополнительные поля для UI (не из backend)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<String> images;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final int viewCount;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final int favoriteCount;

  const MarketProductModel({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.currency = 'KZT',
    this.available = true,
    this.createdAt,
    this.updatedAt,
    this.images = const [],
    this.viewCount = 0,
    this.favoriteCount = 0,
  });

  factory MarketProductModel.fromJson(Map<String, dynamic> json) =>
      _$MarketProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketProductModelToJson(this);

  // Helpers для UI
  String get priceFormatted => '${price.toStringAsFixed(0)} ₸';
  bool get isProduct => kind == 'product';
  bool get isService => kind == 'service';
  bool get isAd => kind == 'ad';
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
