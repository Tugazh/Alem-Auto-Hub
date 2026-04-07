import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/warehouse_part_model.dart';

/// Warehouse Service для работы с /api/v1/warehouse
///
/// Backend endpoints:
/// - GET /warehouse/parts - Список запчастей
/// - POST /warehouse/parts - Создать запчасть
/// - GET /warehouse/parts/:id - Получить запчасть
/// - PUT /warehouse/parts/:id - Обновить запчасть
/// - DELETE /warehouse/parts/:id - Удалить запчасть
/// - POST /warehouse/parts/:id/check - Проверить наличие
/// - POST /warehouse/parts/:id/stock - Обновить остаток
class WarehouseService {
  final ApiClient _apiClient;

  WarehouseService(this._apiClient);

  /// Получить список запчастей
  Future<List<WarehousePartModel>> getParts({
    String? category,
    String? search,
    bool? inStock,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/warehouse/parts',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          if (inStock != null) 'in_stock': inStock,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is! List) {
        debugPrint('⚠️ Warehouse API: unexpected response format');
        return [];
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => WarehousePartModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Failed to load parts: $e');
      return [];
    }
  }

  /// Получить запчасть по ID
  Future<WarehousePartModel?> getPart(String id) async {
    try {
      final response = await _apiClient.get('/warehouse/parts/$id');
      return WarehousePartModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to load part: $e');
      return null;
    }
  }

  /// Создать новую запчасть
  Future<WarehousePartModel?> createPart({
    required String name,
    required String partNumber,
    required String category,
    String? manufacturer,
    String? description,
    double? price,
    String currency = 'KZT',
    int quantityInStock = 0,
    int minStockLevel = 0,
  }) async {
    try {
      final response = await _apiClient.post(
        '/warehouse/parts',
        data: {
          'name': name,
          'part_number': partNumber,
          'category': category,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          'currency': currency,
          'quantity_in_stock': quantityInStock,
          'min_stock_level': minStockLevel,
        },
      );

      return WarehousePartModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to create part: $e');
      return null;
    }
  }

  /// Обновить запчасть
  Future<WarehousePartModel?> updatePart({
    required String id,
    String? name,
    String? partNumber,
    String? category,
    String? manufacturer,
    String? description,
    double? price,
    int? quantityInStock,
    int? minStockLevel,
  }) async {
    try {
      final response = await _apiClient.put(
        '/warehouse/parts/$id',
        data: {
          if (name != null) 'name': name,
          if (partNumber != null) 'part_number': partNumber,
          if (category != null) 'category': category,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          if (quantityInStock != null) 'quantity_in_stock': quantityInStock,
          if (minStockLevel != null) 'min_stock_level': minStockLevel,
        },
      );

      return WarehousePartModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to update part: $e');
      return null;
    }
  }

  /// Проверить наличие запчасти
  Future<Map<String, dynamic>?> checkAvailability(
    String id,
    int quantity,
  ) async {
    try {
      final response = await _apiClient.post(
        '/warehouse/parts/$id/check',
        data: {'quantity': quantity},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Failed to check availability: $e');
      return null;
    }
  }

  /// Обновить остаток (увеличить или уменьшить)
  Future<WarehousePartModel?> updateStock({
    required String id,
    required int quantity,
    String operation = 'add', // 'add' или 'subtract'
  }) async {
    try {
      final response = await _apiClient.post(
        '/warehouse/parts/$id/stock',
        data: {'quantity': quantity, 'operation': operation},
      );

      return WarehousePartModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ Failed to update stock: $e');
      return null;
    }
  }

  /// Удалить запчасть
  Future<bool> deletePart(String id) async {
    try {
      await _apiClient.delete('/warehouse/parts/$id');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete part: $e');
      return false;
    }
  }
}
