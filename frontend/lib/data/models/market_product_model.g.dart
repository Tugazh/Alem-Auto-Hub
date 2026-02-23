// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketProductModel _$MarketProductModelFromJson(Map<String, dynamic> json) =>
    MarketProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      sellerId: json['sellerId'] as String,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      available: json['available'] as bool? ?? true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
      condition: json['condition'] as String?,
      brand: json['brand'] as String?,
      location: json['location'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MarketProductModelToJson(MarketProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'sellerId': instance.sellerId,
      'images': instance.images,
      'available': instance.available,
      'viewCount': instance.viewCount,
      'favoriteCount': instance.favoriteCount,
      'condition': instance.condition,
      'brand': instance.brand,
      'location': instance.location,
      'specifications': instance.specifications,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
