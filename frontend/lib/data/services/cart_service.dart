import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/cart_item_model.dart';
import '../mock/mock_data.dart';

class CartService {
  final ApiClient _apiClient;

  CartService(this._apiClient);

  Future<List<CartItemModel>> getCart() async {
    try {
      final response = await _apiClient.get('/cart');
      if (response.data is! List) {
        return MockData.mockCartItems;
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map(CartItemModel.fromJson).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load cart: $e');
      return MockData.mockCartItems;
    }
  }

  Future<CartItemModel> addItem(CartItemModel item) async {
    try {
      final response = await _apiClient.post('/cart', data: item.toJson());
      return CartItemModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return item;
    }
  }

  Future<CartItemModel> updateItem({
    required String id,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.put(
        '/cart/$id',
        data: {'quantity': quantity},
      );
      return CartItemModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      final original = MockData.mockCartItems.firstWhere((i) => i.id == id);
      return CartItemModel(
        id: original.id,
        productId: original.productId,
        title: original.title,
        price: original.price,
        quantity: quantity,
        imageUrl: original.imageUrl,
      );
    }
  }

  Future<void> removeItem(String id) async {
    try {
      await _apiClient.delete('/cart/$id');
    } catch (_) {}
  }
}
