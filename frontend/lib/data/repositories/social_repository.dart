import '../../core/error/result.dart';
import '../../core/error/failures.dart';
import '../models/social_post_model.dart';
import '../datasources/social_remote_data_source.dart';
import '../datasources/social_local_data_source.dart';
import '../../core/network/network_info.dart';

/// Repository for social feed with offline-first strategy
abstract class SocialRepository {
  Future<Result<List<SocialPostModel>>> getFeed({String? filter});
  Future<Result<List<SocialPostModel>>> refreshFeed();
  Future<Result<SocialPostModel>> getPost(String postId);
  Future<Result<SocialPostModel>> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
  });
  Future<Result<void>> likePost(String postId);
  Future<Result<void>> addComment({
    required String postId,
    required String content,
  });
  Future<Result<void>> deletePost(String postId);
}

/// Implementation of SocialRepository
class SocialRepositoryImpl implements SocialRepository {
  final SocialRemoteDataSource remoteDataSource;
  final SocialLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SocialRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<SocialPostModel>>> getFeed({String? filter}) async {
    if (await networkInfo.isConnected) {
      try {
        final posts = await remoteDataSource.getFeed(filter: filter);

        // Cache the result
        await localDataSource.cachePosts(posts);

        return Success(posts);
      } catch (e) {
        // Fallback to cache
        final cachedPosts = await localDataSource.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          return Success(cachedPosts);
        }

        return ResultFailure(_mapExceptionToFailure(e));
      }
    } else {
      // No network, use cache
      final cachedPosts = await localDataSource.getCachedPosts();
      if (cachedPosts.isNotEmpty) {
        return Success(cachedPosts);
      }

      return const ResultFailure(
        NetworkFailure(message: 'Нет подключения к интернету'),
      );
    }
  }

  @override
  Future<Result<List<SocialPostModel>>> refreshFeed() async {
    try {
      final posts = await remoteDataSource.getFeed();

      // Update cache
      await localDataSource.cachePosts(posts);

      return Success(posts);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<SocialPostModel>> getPost(String postId) async {
    try {
      final post = await remoteDataSource.getPost(postId);
      return Success(post);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<SocialPostModel>> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
  }) async {
    try {
      final post = await remoteDataSource.createPost(
        content: content,
        mediaUrls: mediaUrls,
        tags: tags,
      );

      // Invalidate cache
      await localDataSource.clearCache();

      return Success(post);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> likePost(String postId) async {
    try {
      await remoteDataSource.likePost(postId);
      return const Success(null);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      await remoteDataSource.addComment(postId: postId, content: content);

      // Invalidate cache
      await localDataSource.clearCache();

      return const Success(null);
    } catch (e) {
      return ResultFailure(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);

      // Invalidate cache
      await localDataSource.clearCache();

      return const Success(null);
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
      return const NotFoundFailure(message: 'Пост не найден');
    } else if (e.toString().contains('500')) {
      return const ServerFailure(message: 'Ошибка сервера');
    }
    return UnknownFailure(message: e.toString());
  }
}
