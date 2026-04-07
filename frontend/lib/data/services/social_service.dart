import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/social_post_model.dart';
import '../mock/mock_data.dart';

/// Сервис социальной сети для работы с /api/v1/social.
///
/// Эндпоинты:
/// - GET /social/posts - Список постов
/// - POST /social/posts - Создать пост
/// - GET /social/posts/:id - Получить пост
/// - POST /social/posts/:id/like - Лайкнуть пост
/// - POST /social/posts/:id/comment - Комментировать пост
/// - POST /social/upload - Загрузить медиа
class SocialService {
  final ApiClient _apiClient;

  SocialService(this._apiClient);

  /// Получить ленту постов.
  Future<List<SocialPostModel>> getFeed({
    String? filter, // варианты: 'all', 'following', 'popular'
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get(
        '/social/posts',
        queryParameters: {
          if (filter != null) 'filter': filter,
          if (page != null) 'page': page,
          if (limit != null) 'limit': limit,
        },
      );

      // Если бекенд вернул заглушку, используем mock-данные.
      if (response.data is! List) {
        debugPrint('Backend не реализован, используются mock-данные');
        return MockData.mockSocialPosts;
      }

      final list = List<Map<String, dynamic>>.from(response.data);
      return list.map((json) => SocialPostModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Не удалось загрузить из бекенда: $e. Используем mock-данные');
      return MockData.mockSocialPosts;
    }
  }

  /// Получить пост по ID
  Future<SocialPostModel> getPost(String id) async {
    final response = await _apiClient.get('/social/posts/$id');
    return SocialPostModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Создать новый пост
  Future<SocialPostModel> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
  }) async {
    final response = await _apiClient.post(
      '/social/posts',
      data: {
        'content': content,
        if (mediaUrls != null) 'media_urls': mediaUrls,
        if (tags != null) 'tags': tags,
      },
    );

    return SocialPostModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Лайкнуть пост
  Future<void> likePost(String postId) async {
    await _apiClient.post('/social/posts/$postId/like');
  }

  /// Добавить комментарий
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      '/social/posts/$postId/comment',
      data: {'content': content},
    );

    return response.data as Map<String, dynamic>;
  }

  /// Получить комментарии к посту
  Future<List<dynamic>> getComments(String postId) async {
    try {
      final response = await _apiClient.get('/social/posts/$postId/comments');
      if (response.data is! List) {
        return [];
      }
      return response.data as List<dynamic>;
    } catch (e) {
      debugPrint('Не удалось загрузить комментарии: $e');
      return [];
    }
  }

  /// Загрузить медиа файл (фото/видео)
  /// Возвращает URL загруженного файла в MinIO
  Future<String> uploadMedia(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _apiClient.post('/social/upload', data: formData);

    return response.data['url'] as String;
  }
}
