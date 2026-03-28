import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'market_event.dart';
import 'market_state.dart';
import '../../../data/repositories/market_repository.dart';
import '../../../data/models/market_product_model.dart';
import '../../../core/error/result.dart';

/// BLoC for managing market products
class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final MarketRepository repository;
  final Logger _logger = Logger();

  MarketBloc(this.repository) : super(const MarketInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<ToggleFavorite>(_onToggleFavorite);
    on<CreateProduct>(_onCreateProduct);
  }

  /// Load products (cache-first strategy)
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('📥 Loading products...');
    emit(const MarketLoading());

    final result = await repository.getProducts();

    result.fold(
      (failure) {
        _logger.e('❌ Failed to load products: ${failure.message}');
        emit(MarketError(failure));
      },
      (products) {
        _logger.i('✅ Loaded ${products.length} products');
        emit(
          MarketLoaded(
            products: products,
            filteredProducts: products,
            isFromCache: result is Success,
          ),
        );
      },
    );
  }

  /// Refresh products (force network)
  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('🔄 Refreshing products...');

    if (state is MarketLoaded) {
      emit(const MarketLoading(isRefreshing: true));
    } else {
      emit(const MarketLoading());
    }

    final result = await repository.refreshProducts();

    result.fold(
      (failure) {
        _logger.e('❌ Failed to refresh: ${failure.message}');

        if (state is MarketLoaded) {
          final currentState = state as MarketLoaded;
          emit(MarketError(failure, cachedProducts: currentState.products));
        } else {
          emit(MarketError(failure));
        }
      },
      (products) {
        _logger.i('✅ Refreshed ${products.length} products');
        final currentState = state;
        emit(
          MarketLoaded(
            products: products,
            filteredProducts: _applyFilters(
              products,
              currentState is MarketLoaded
                  ? currentState.currentCategory
                  : null,
              currentState is MarketLoaded ? currentState.searchQuery : null,
            ),
          ),
        );
      },
    );
  }

  /// Search products by query
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<MarketState> emit,
  ) async {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;

      final filtered = _applyFilters(
        currentState.products,
        currentState.currentCategory,
        event.query.isEmpty ? null : event.query,
      );

      emit(
        currentState.copyWith(
          filteredProducts: filtered,
          searchQuery: event.query.isEmpty ? null : event.query,
        ),
      );

      _logger.i('🔍 Search: "${event.query}" (${filtered.length} results)');
    }
  }

  /// Filter products by category
  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<MarketState> emit,
  ) async {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;

      final filtered = _applyFilters(
        currentState.products,
        event.category == 'all' ? null : event.category,
        currentState.searchQuery,
      );

      emit(
        currentState.copyWith(
          filteredProducts: filtered,
          currentCategory: event.category == 'all' ? null : event.category,
        ),
      );

      _logger.i('🏷️ Category: ${event.category} (${filtered.length} items)');
    }
  }

  /// Load product details
  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('📦 Loading product details: ${event.productId}');
    emit(const MarketLoading());

    final result = await repository.getProductDetails(event.productId);

    result.fold(
      (failure) {
        _logger.e('❌ Failed to load product: ${failure.message}');
        emit(MarketError(failure));
      },
      (product) {
        _logger.i('✅ Product loaded: ${product.title}');
        emit(MarketProductDetailsLoaded(product));
      },
    );
  }

  /// Toggle favorite status
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<MarketState> emit,
  ) async {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      final favoriteIds = Set<String>.from(currentState.favoriteIds);

      if (favoriteIds.contains(event.productId)) {
        favoriteIds.remove(event.productId);
        _logger.i('💔 Removed from favorites: ${event.productId}');
      } else {
        favoriteIds.add(event.productId);
        _logger.i('❤️ Added to favorites: ${event.productId}');
      }

      emit(currentState.copyWith(favoriteIds: favoriteIds));
    }
  }

  /// Create new product
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('➕ Creating product: ${event.title}');
    emit(const MarketOperationInProgress('create'));

    final result = await repository.createProduct(
      title: event.title,
      description: event.description,
      price: event.price,
      category: event.category,
      images: event.images,
    );

    result.fold(
      (failure) {
        _logger.e('❌ Failed to create product: ${failure.message}');
        emit(MarketError(failure));
      },
      (product) {
        _logger.i('✅ Product created: ${product.id}');
        emit(const MarketOperationSuccess('create', 'Товар создан'));

        // Reload products
        add(const LoadProducts());
      },
    );
  }

  /// Apply search and category filters
  List<MarketProductModel> _applyFilters(
    List<MarketProductModel> products,
    String? category,
    String? searchQuery,
  ) {
    var filtered = products;

    // Apply category filter
    if (category != null && category != 'all') {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            (p.brand?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }
}
