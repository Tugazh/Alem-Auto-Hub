import '../../core/error/result.dart';
import '../../core/error/failures.dart';
import '../models/market_product_model.dart';
import '../datasources/market_remote_data_source.dart';
import '../datasources/market_local_data_source.dart';
import '../../core/network/network_info.dart';

/// Repository for market products with offline-first strategy
abstract class MarketRepository {
  Future<Result<List<MarketProductModel>>> getProducts({
    String? category,
    String? search,
  });
  Future<Result<List<MarketProductModel>>> refreshProducts();
  Future<Result<MarketProductModel>> getProductDetails(String id);
  Future<Result<MarketProductModel>> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    List<String>? images,
  });
}

/// Implementation of MarketRepository
class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource remoteDataSource;
  final MarketLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MarketRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<MarketProductModel>>> getProducts({
    String? category,
    String? search,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProducts(
          category: category,
          search: search,
        );

        // Cache the result
        await localDataSource.cacheProducts(products);

        return Success(products);
      } catch (e) {
        // Fallback to cache
        final cachedProducts = await localDataSource.getCachedProducts();
        if (cachedProducts.isNotEmpty) {
          return Success(cachedProducts);
        }

        return ResultFailure(_mapExceptionToFailure(e));
      }
    } else {
      // No network, use cache
      final cachedProducts = await localDataSource.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return Success(cachedProducts);
      }

      return const ResultFailure(
        NetworkFailure(message: 'Нет подключения к интернету'),
      );
    }
  }

  @override
  Future<Result<List<MarketProductModel>>> refreshProducts() async {
    try {
      final products = await remoteDataSource.getProducts();

      // Update cache
      await localDataSource.cacheProducts(products);

      return Success(products);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<MarketProductModel>> getProductDetails(String id) async {
    try {
      final product = await remoteDataSource.getProduct(id);
      return Success(product);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<MarketProductModel>> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    List<String>? images,
  }) async {
    try {
      final product = await remoteDataSource.createProduct(
        title: title,
        description: description,
        price: price,
        category: category,
        images: images,
      );

      // Invalidate cache
      await localDataSource.clearCache();

      return Success(product);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  /// Map exceptions to typed failures
  Failure _mapExceptionToFailure(Object e) {
    if (e.toString().contains('SocketException') ||
        e.toString().contains('NetworkException')) {
      return const NetworkFailure(message: 'Нет подключения к серверу');
    } else if (e.toString().contains('TimeoutException')) {
      return const TimeoutFailure(message: 'Превышено время ожидания');
    } else if (e.toString().contains('401')) {
      return const AuthFailure(message: 'Требуется авторизация');
    } else if (e.toString().contains('404')) {
      return const NotFoundFailure(message: 'Товар не найден');
    } else if (e.toString().contains('500')) {
      return const ServerFailure(message: 'Ошибка сервера');
    }
    return UnknownFailure(message: e.toString());
  }
}
