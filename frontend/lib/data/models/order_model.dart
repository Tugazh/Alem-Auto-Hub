import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<CartItemModel> items;

  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id']?.toString() ?? '',
    status: json['status']?.toString() ?? 'created',
    total: (json['total'] as num?)?.toDouble() ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now(),
    items: (json['items'] as List<dynamic>? ?? [])
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'total': total,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
  };
}
