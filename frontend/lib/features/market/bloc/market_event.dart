import 'package:equatable/equatable.dart';

/// Market Events
abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

/// Load products (cache-first)
class LoadProducts extends MarketEvent {
  const LoadProducts();
}

/// Refresh products (force network)
class RefreshProducts extends MarketEvent {
  const RefreshProducts();
}

/// Search products by query
class SearchProducts extends MarketEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter products by category
class FilterProductsByCategory extends MarketEvent {
  final String category;

  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Load product details
class LoadProductDetails extends MarketEvent {
  final String productId;

  const LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Add product to favorites
class ToggleFavorite extends MarketEvent {
  final String productId;

  const ToggleFavorite(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Create new product
class CreateProduct extends MarketEvent {
  final String title;
  final String description;
  final double price;
  final String category;
  final List<String>? images;

  const CreateProduct({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.images,
  });

  @override
  List<Object?> get props => [title, description, price, category, images];
}
