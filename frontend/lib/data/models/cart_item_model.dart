class CartItemModel {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get total => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id']?.toString() ?? '',
    productId: json['productId']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    imageUrl: json['imageUrl']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'title': title,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };
}
