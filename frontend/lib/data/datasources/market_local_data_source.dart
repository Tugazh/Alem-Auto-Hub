import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/market_product_model.dart';

/// Local data source for market products (cache layer)
class MarketLocalDataSource {
  final SharedPreferences prefs;

  static const String _cacheKey = 'cached_market_products';
  static const String _timestampKey = 'market_products_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);

  MarketLocalDataSource(this.prefs);

  /// Get cached products if they exist and not expired
  Future<List<MarketProductModel>> getCachedProducts() async {
    try {
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString == null) return [];

      // Check cache expiry
      final timestamp = prefs.getInt(_timestampKey) ?? 0;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > _cacheExpiry) {
        // Cache expired
        await clearCache();
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => MarketProductModel.fromJson(json)).toList();
    } catch (e) {
      // On error, clear corrupted cache
      await clearCache();
      return [];
    }
  }

  /// Cache products to local storage
  Future<void> cacheProducts(List<MarketProductModel> products) async {
    try {
      final jsonString = jsonEncode(
        products.map((product) => product.toJson()).toList(),
      );

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear cached products
  Future<void> clearCache() async {
    await prefs.remove(_cacheKey);
    await prefs.remove(_timestampKey);
  }
}
