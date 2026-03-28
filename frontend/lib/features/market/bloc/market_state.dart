import 'package:equatable/equatable.dart';
import '../../../data/models/market_product_model.dart';
import '../../../core/error/failures.dart';

/// Market States
abstract class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MarketInitial extends MarketState {
  const MarketInitial();
}

/// Loading state
class MarketLoading extends MarketState {
  final bool isRefreshing;

  const MarketLoading({this.isRefreshing = false});

  @override
  List<Object?> get props => [isRefreshing];
}

/// Products loaded successfully
class MarketLoaded extends MarketState {
  final List<MarketProductModel> products;
  final List<MarketProductModel> filteredProducts;
  final String? currentCategory;
  final String? searchQuery;
  final Set<String> favoriteIds;
  final bool isFromCache;

  const MarketLoaded({
    required this.products,
    required this.filteredProducts,
    this.currentCategory,
    this.searchQuery,
    this.favoriteIds = const {},
    this.isFromCache = false,
  });

  /// Get products by category
  int get productCount => filteredProducts.length;

  /// Get favorite products
  List<MarketProductModel> get favoriteProducts =>
      products.where((p) => favoriteIds.contains(p.id)).toList();

  MarketLoaded copyWith({
    List<MarketProductModel>? products,
    List<MarketProductModel>? filteredProducts,
    String? currentCategory,
    String? searchQuery,
    Set<String>? favoriteIds,
    bool? isFromCache,
  }) {
    return MarketLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      currentCategory: currentCategory ?? this.currentCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    products,
    filteredProducts,
    currentCategory,
    searchQuery,
    favoriteIds,
    isFromCache,
  ];
}

/// Product details loaded
class MarketProductDetailsLoaded extends MarketState {
  final MarketProductModel product;

  const MarketProductDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

/// Error state
class MarketError extends MarketState {
  final Failure failure;
  final List<MarketProductModel>? cachedProducts;

  const MarketError(this.failure, {this.cachedProducts});

  /// Get user-friendly error message
  String get errorMessage {
    if (failure is NetworkFailure) {
      return 'Нет подключения к интернету';
    } else if (failure is ServerFailure) {
      return 'Ошибка сервера. Попробуйте позже';
    } else if (failure is TimeoutFailure) {
      return 'Превышено время ожидания';
    }
    return failure.message;
  }

  @override
  List<Object?> get props => [failure, cachedProducts];
}

/// Operation in progress (create, update, delete)
class MarketOperationInProgress extends MarketState {
  final String operationType;

  const MarketOperationInProgress(this.operationType);

  @override
  List<Object?> get props => [operationType];
}

/// Operation completed successfully
class MarketOperationSuccess extends MarketState {
  final String operationType;
  final String message;

  const MarketOperationSuccess(this.operationType, this.message);

  @override
  List<Object?> get props => [operationType, message];
}
