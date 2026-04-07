import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get('/orders');
      if (response.data is! List) {
        return [];
      }
      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map(OrderModel.fromJson).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить заказы: $e');
      return [];
    }
  }

  Future<OrderModel?> getOrder(String id) async {
    try {
      final response = await _apiClient.get('/orders/$id');
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel> createOrder({required List<CartItemModel> items}) async {
    final total = items.fold<double>(0, (sum, item) => sum + item.total);
    try {
      final response = await _apiClient.post(
        '/orders',
        data: {
          'items': items.map((item) => item.toJson()).toList(),
          'total': total,
        },
      );
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return OrderModel(
        id: 'order-${DateTime.now().millisecondsSinceEpoch}',
        status: 'created',
        total: total,
        createdAt: DateTime.now(),
        items: items,
      );
    }
  }
}
