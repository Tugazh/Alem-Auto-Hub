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
        return MockData.mockCartItems.cast<CartItemModel>();
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map(CartItemModel.fromJson).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить корзину: $e');
      return MockData.mockCartItems.cast<CartItemModel>();
    }
  }

  Future<CartItemModel> addItem(CartItemModel item) async {
    try {
      final response = await _apiClient.post('/cart', data: item.toJson());
      return CartItemModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось добавить товар в корзину: $e');
      final created = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: item.productId,
        title: item.title,
        price: item.price,
        quantity: item.quantity,
        imageUrl: item.imageUrl,
      );
      return created;
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
      final original = MockData.mockCartItems.cast<CartItemModel>().firstWhere(
        (i) => i.id == id,
        orElse: () => CartItemModel(
          id: id,
          productId: '',
          title: 'Unknown',
          price: 0,
          quantity: quantity,
          imageUrl: '',
        ),
      );
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
