import 'package:equatable/equatable.dart';

/// Social Events
abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object?> get props => [];
}

/// Load social feed (cache-first)
class LoadFeed extends SocialEvent {
  const LoadFeed();
}

/// Refresh feed (force network)
class RefreshFeed extends SocialEvent {
  const RefreshFeed();
}

/// Filter feed by type
class FilterFeed extends SocialEvent {
  final String filter; // 'all', 'following', 'popular'

  const FilterFeed(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Load post details
class LoadPostDetails extends SocialEvent {
  final String postId;

  const LoadPostDetails(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Create new post
class CreatePost extends SocialEvent {
  final String content;
  final List<String>? mediaUrls;
  final List<String>? tags;

  const CreatePost({required this.content, this.mediaUrls, this.tags});

  @override
  List<Object?> get props => [content, mediaUrls, tags];
}

/// Toggle like on post
class ToggleLike extends SocialEvent {
  final String postId;

  const ToggleLike(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Add comment to post
class AddComment extends SocialEvent {
  final String postId;
  final String content;

  const AddComment({required this.postId, required this.content});

  @override
  List<Object?> get props => [postId, content];
}

/// Delete post
class DeletePost extends SocialEvent {
  final String postId;

  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}
