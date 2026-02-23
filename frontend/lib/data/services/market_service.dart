import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/market_product_model.dart';
import '../mock/mock_data.dart';

/// Market Service для работы с /api/v1/market endpoints
///
/// Endpoints:
/// - GET /market - Список товаров
/// - POST /market - Создать товар
/// - GET /market/:id - Получить товар
/// - PUT /market/:id - Обновить товар
/// - DELETE /market/:id - Удалить товар
class MarketService {
  final ApiClient _apiClient;

  MarketService(this._apiClient);

  /// Получить список товаров с фильтрами
  Future<List<MarketProductModel>> getProducts({
    String? category,
    String? search,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get(
        '/market',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );

      // Если бэкенд вернул placeholder, используем mock данные
      if (response.data is! List) {
        debugPrint('⚠️ Backend not implemented, using mock data');
        return MockData.mockMarketProducts;
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => MarketProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load from backend: $e, using mock data');
      return MockData.mockMarketProducts;
    }
  }

  /// Получить товар по ID
  Future<MarketProductModel> getProduct(String id) async {
    final response = await _apiClient.get('/market/$id');
    return MarketProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Создать новый товар
  Future<MarketProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    List<String>? images,
  }) async {
    final response = await _apiClient.post(
      '/market',
      data: {
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        if (images != null) 'images': images,
      },
    );

    return MarketProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Обновить товар
  Future<MarketProductModel> updateProduct(
    String id, {
    String? title,
    String? description,
    double? price,
    bool? available,
  }) async {
    final response = await _apiClient.put(
      '/market/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (available != null) 'available': available,
      },
    );

    return MarketProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Удалить товар
  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('/market/$id');
  }
}
