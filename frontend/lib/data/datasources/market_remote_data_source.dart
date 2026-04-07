import '../models/market_product_model.dart';
import '../services/market_service.dart';

/// Remote data source for market products (API layer)
class MarketRemoteDataSource {
  final MarketService marketService;

  MarketRemoteDataSource(this.marketService);

  /// Получить список товаров
  Future<List<MarketProductModel>> getProducts({
    String? category,
    String? search,
  }) async {
    return await marketService.getProducts(category: category, search: search);
  }

  /// Получить список услуг
  Future<List<MarketProductModel>> getServices({
    String? category,
    String? search,
  }) async {
    return await marketService.getServices(category: category, search: search);
  }

  /// Получить список объявлений
  Future<List<MarketProductModel>> getAds({
    String? category,
    String? search,
  }) async {
    return await marketService.getAds(category: category, search: search);
  }

  /// Получить конкретный товар/услугу/объявление по ID
  /// kind: 'products', 'services', 'ads'
  Future<MarketProductModel?> getItem(String kind, String id) async {
    return await marketService.getItem(kind, id);
  }

  /// Создать новый товар
  Future<MarketProductModel?> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    String currency = 'KZT',
  }) async {
    return await marketService.createProduct(
      title: title,
      description: description,
      price: price,
      category: category,
      currency: currency,
    );
  }

  /// Создать новую услугу
  Future<MarketProductModel?> createService({
    required String title,
    required String description,
    required double price,
    required String category,
    String currency = 'KZT',
  }) async {
    return await marketService.createService(
      title: title,
      description: description,
      price: price,
      category: category,
      currency: currency,
    );
  }

  /// Обновить товар/услугу/объявление
  Future<MarketProductModel?> updateItem(
    String kind,
    String id, {
    String? title,
    String? description,
    double? price,
    String? category,
    bool? available,
  }) async {
    return await marketService.updateItem(
      kind,
      id,
      title: title,
      description: description,
      price: price,
      category: category,
      available: available,
    );
  }

  /// Удалить товар/услугу/объявление
  Future<bool> deleteItem(String kind, String id) async {
    return await marketService.deleteItem(kind, id);
  }
}
