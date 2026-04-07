import '../models/social_post_model.dart';
import '../services/social_service.dart';

/// Remote data source for social posts (API layer)
class SocialRemoteDataSource {
  final SocialService socialService;

  SocialRemoteDataSource(this.socialService);

  Future<List<SocialPostModel>> getFeed({String? filter}) async {
    return await socialService.getFeed(filter: filter);
  }

  Future<SocialPostModel> getPost(String postId) async {
    return await socialService.getPost(postId);
  }

  Future<SocialPostModel> createPost({
    required String content,
    List<String>? mediaUrls,
    List<String>? tags,
  }) async {
    return await socialService.createPost(
      content: content,
      mediaUrls: mediaUrls,
      tags: tags,
    );
  }

  Future<void> likePost(String postId) async {
    await socialService.likePost(postId);
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    await socialService.addComment(postId: postId, content: content);
  }

  Future<void> deletePost(String postId) async {
    // TODO: Реализовать после добавления DELETE /social/posts/:id на бекенде.
    throw UnimplementedError('Delete post not yet implemented in backend');
  }
}
