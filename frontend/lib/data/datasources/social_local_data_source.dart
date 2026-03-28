import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/social_post_model.dart';

/// Local data source for social posts (cache layer)
class SocialLocalDataSource {
  final SharedPreferences prefs;

  static const String _cacheKey = 'cached_social_posts';
  static const String _timestampKey = 'social_posts_timestamp';
  static const Duration _cacheExpiry = Duration(
    hours: 1,
  ); // Shorter for social content

  SocialLocalDataSource(this.prefs);

  /// Get cached posts if they exist and not expired
  Future<List<SocialPostModel>> getCachedPosts() async {
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
      return jsonList.map((json) => SocialPostModel.fromJson(json)).toList();
    } catch (e) {
      // On error, clear corrupted cache
      await clearCache();
      return [];
    }
  }

  /// Cache posts to local storage
  Future<void> cachePosts(List<SocialPostModel> posts) async {
    try {
      final jsonString = jsonEncode(
        posts.map((post) => post.toJson()).toList(),
      );

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear cached posts
  Future<void> clearCache() async {
    await prefs.remove(_cacheKey);
    await prefs.remove(_timestampKey);
  }
}
