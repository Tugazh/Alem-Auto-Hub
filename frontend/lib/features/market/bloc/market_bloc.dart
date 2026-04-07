import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'market_event.dart';
import 'market_state.dart';
import '../../../data/repositories/market_repository.dart';
import '../../../data/models/market_product_model.dart';
import '../../../core/error/result.dart';

/// BLoC для управления товарами маркетплейса.
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

  /// Загрузить товары (стратегия cache-first).
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('Загрузка товаров...');
    emit(const MarketLoading());

    final result = await repository.getProducts();

    result.fold(
      (failure) {
        _logger.e('Не удалось загрузить товары: ${failure.message}');
        emit(MarketError(failure));
      },
      (products) {
        _logger.i('Загружено товаров: ${products.length}');
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

  /// Обновить товары (принудительно из сети).
  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('Обновление товаров...');

    if (state is MarketLoaded) {
      emit(const MarketLoading(isRefreshing: true));
    } else {
      emit(const MarketLoading());
    }

    final result = await repository.refreshProducts();

    result.fold(
      (failure) {
        _logger.e('Не удалось обновить товары: ${failure.message}');

        if (state is MarketLoaded) {
          final currentState = state as MarketLoaded;
          emit(MarketError(failure, cachedProducts: currentState.products));
        } else {
          emit(MarketError(failure));
        }
      },
      (products) {
        _logger.i('Обновлено товаров: ${products.length}');
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

  /// Поиск товаров по запросу.
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

      _logger.i('Поиск: "${event.query}" (результатов: ${filtered.length})');
    }
  }

  /// Фильтрация товаров по категории.
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

      _logger.i('Категория: ${event.category} (элементов: ${filtered.length})');
    }
  }

  /// Загрузить детали товара.
  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('Загрузка деталей товара: ${event.productId}');
    emit(const MarketLoading());

    final result = await repository.getProductDetails(event.productId);

    result.fold(
      (failure) {
        _logger.e('Не удалось загрузить товар: ${failure.message}');
        emit(MarketError(failure));
      },
      (product) {
        _logger.i('Товар загружен: ${product.title}');
        emit(MarketProductDetailsLoaded(product));
      },
    );
  }

  /// Переключить статус избранного.
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<MarketState> emit,
  ) async {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      final favoriteIds = Set<String>.from(currentState.favoriteIds);

      if (favoriteIds.contains(event.productId)) {
        favoriteIds.remove(event.productId);
        _logger.i('Удалено из избранного: ${event.productId}');
      } else {
        favoriteIds.add(event.productId);
        _logger.i('Добавлено в избранное: ${event.productId}');
      }

      emit(currentState.copyWith(favoriteIds: favoriteIds));
    }
  }

  /// Создать новый товар.
  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<MarketState> emit,
  ) async {
    _logger.i('Создание товара: ${event.title}');
    emit(const MarketOperationInProgress('create'));

    final result = await repository.createProduct(
      title: event.title,
      description: event.description,
      price: event.price,
      category: event.category,
      // images: event.images, // TODO: Добавить поддержку изображений в репозитории.
    );

    result.fold(
      (failure) {
        _logger.e('Не удалось создать товар: ${failure.message}');
        emit(MarketError(failure));
      },
      (product) {
        _logger.i('Товар создан: ${product.id}');
        emit(const MarketOperationSuccess('create', 'Товар создан'));

        // Перезагрузка списка товаров.
        add(const LoadProducts());
      },
    );
  }

  /// Применить фильтры поиска и категории.
  List<MarketProductModel> _applyFilters(
    List<MarketProductModel> products,
    String? category,
    String? searchQuery,
  ) {
    var filtered = products;

    // Применяем фильтр категории.
    if (category != null && category != 'all') {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }
}
