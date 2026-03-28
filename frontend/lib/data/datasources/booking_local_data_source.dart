import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';

/// Local data source for bookings (cache layer)
class BookingLocalDataSource {
  final SharedPreferences prefs;

  static const String _cacheKey = 'cached_bookings';
  static const String _timestampKey = 'bookings_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24);

  BookingLocalDataSource(this.prefs);

  /// Get cached bookings if they exist and not expired
  Future<List<BookingModel>> getCachedBookings() async {
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
      return jsonList.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      // On error, clear corrupted cache
      await clearCache();
      return [];
    }
  }

  /// Cache bookings to local storage
  Future<void> cacheBookings(List<BookingModel> bookings) async {
    try {
      final jsonString = jsonEncode(
        bookings.map((booking) => booking.toJson()).toList(),
      );

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail, logging would be handled by repository
    }
  }

  /// Clear cached bookings
  Future<void> clearCache() async {
    await prefs.remove(_cacheKey);
    await prefs.remove(_timestampKey);
  }
}
