import '../models/market_product_model.dart';
import '../services/market_service.dart';

/// Remote data source for market products (API layer)
class MarketRemoteDataSource {
  final MarketService marketService;

  MarketRemoteDataSource(this.marketService);

  Future<List<MarketProductModel>> getProducts({
    String? category,
    String? search,
  }) async {
    return await marketService.getProducts(category: category, search: search);
  }

  Future<MarketProductModel> getProduct(String id) async {
    return await marketService.getProduct(id);
  }

  Future<MarketProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    List<String>? images,
  }) async {
    return await marketService.createProduct(
      title: title,
      description: description,
      price: price,
      category: category,
      images: images,
    );
  }
}
