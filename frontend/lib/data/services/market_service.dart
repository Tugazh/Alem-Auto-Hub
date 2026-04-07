import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/market_product_model.dart';

/// Market Service для работы с /api/v1/market endpoints
///
/// Backend структура:
/// - GET /market/products - Список товаров (kind=product)
/// - GET /market/services - Список услуг (kind=service)
/// - GET /market/ads - Список объявлений (kind=ad)
/// - POST /market/products - Создать товар
/// - GET /market/products/:id - Получить товар
/// - PUT /market/products/:id - Обновить товар
/// - DELETE /market/products/:id - Удалить товар
class MarketService {
  final ApiClient _apiClient;

  MarketService(this._apiClient);

  /// Получить список товаров (products)
  Future<List<MarketProductModel>> getProducts({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/market/products',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is! List) {
        debugPrint('⚠️ Market API: unexpected response format');
        return [];
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => MarketProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to load products from backend: $e');
      return [];
    }
  }

  /// Получить список услуг (services)
  Future<List<MarketProductModel>> getServices({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/market/services',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is! List) {
        return [];
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => MarketProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to load services from backend: $e');
      return [];
    }
  }

  /// Получить список объявлений (ads)
  Future<List<MarketProductModel>> getAds({
    String? category,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/market/ads',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is! List) {
        return [];
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => MarketProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to load ads from backend: $e');
      return [];
    }
  }

  /// Получить товар/услугу/объявление по ID
  Future<MarketProductModel?> getItem(String kind, String id) async {
    try {
      final response = await _apiClient.get('/market/$kind/$id');
      return MarketProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to load item: $e');
      return null;
    }
  }

  /// Создать новый товар
  Future<MarketProductModel?> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    String currency = 'KZT',
  }) async {
    try {
      final response = await _apiClient.post(
        '/market/products',
        data: {
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'currency': currency,
        },
      );

      return MarketProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to create product: $e');
      return null;
    }
  }

  /// Создать новую услугу
  Future<MarketProductModel?> createService({
    required String title,
    required String description,
    required double price,
    required String category,
    String currency = 'KZT',
  }) async {
    try {
      final response = await _apiClient.post(
        '/market/services',
        data: {
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'currency': currency,
        },
      );

      return MarketProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to create service: $e');
      return null;
    }
  }

  /// Обновить товар
  Future<MarketProductModel?> updateItem(
    String kind,
    String id, {
    String? title,
    String? description,
    double? price,
    String? category,
    bool? available,
  }) async {
    try {
      final response = await _apiClient.put(
        '/market/$kind/$id',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          if (category != null) 'category': category,
          if (available != null) 'available': available,
        },
      );

      return MarketProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to update item: $e');
      return null;
    }
  }

  /// Удалить товар
  Future<bool> deleteItem(String kind, String id) async {
    try {
      await _apiClient.delete('/market/$kind/$id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete item: $e');
      return false;
    }
  }
}
