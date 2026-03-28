import 'package:equatable/equatable.dart';
import '../../../data/models/social_post_model.dart';
import '../../../core/error/failures.dart';

/// Social States
abstract class SocialState extends Equatable {
  const SocialState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SocialInitial extends SocialState {
  const SocialInitial();
}

/// Loading state
class SocialLoading extends SocialState {
  final bool isRefreshing;

  const SocialLoading({this.isRefreshing = false});

  @override
  List<Object?> get props => [isRefreshing];
}

/// Feed loaded successfully
class SocialFeedLoaded extends SocialState {
  final List<SocialPostModel> posts;
  final String currentFilter;
  final Set<String> likedPostIds;
  final bool isFromCache;

  const SocialFeedLoaded({
    required this.posts,
    this.currentFilter = 'all',
    this.likedPostIds = const {},
    this.isFromCache = false,
  });

  /// Get like count for feed
  int get totalLikes => posts.fold(0, (sum, post) => sum + post.likeCount);

  /// Get comment count for feed
  int get totalComments =>
      posts.fold(0, (sum, post) => sum + post.commentCount);

  SocialFeedLoaded copyWith({
    List<SocialPostModel>? posts,
    String? currentFilter,
    Set<String>? likedPostIds,
    bool? isFromCache,
  }) {
    return SocialFeedLoaded(
      posts: posts ?? this.posts,
      currentFilter: currentFilter ?? this.currentFilter,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [posts, currentFilter, likedPostIds, isFromCache];
}

/// Post details loaded
class SocialPostDetailsLoaded extends SocialState {
  final SocialPostModel post;

  const SocialPostDetailsLoaded(this.post);

  @override
  List<Object?> get props => [post];
}

/// Error state
class SocialError extends SocialState {
  final Failure failure;
  final List<SocialPostModel>? cachedPosts;

  const SocialError(this.failure, {this.cachedPosts});

  /// Get user-friendly error message
  String get errorMessage {
    if (failure is NetworkFailure) {
      return 'Нет подключения к интернету';
    } else if (failure is ServerFailure) {
      return 'Ошибка сервера. Попробуйте позже';
    } else if (failure is TimeoutFailure) {
      return 'Превышено время ожидания';
    }
    return failure.message;
  }

  @override
  List<Object?> get props => [failure, cachedPosts];
}

/// Operation in progress (create, like, comment, delete)
class SocialOperationInProgress extends SocialState {
  final String operationType;

  const SocialOperationInProgress(this.operationType);

  @override
  List<Object?> get props => [operationType];
}

/// Operation completed successfully
class SocialOperationSuccess extends SocialState {
  final String operationType;
  final String message;

  const SocialOperationSuccess(this.operationType, this.message);

  @override
  List<Object?> get props => [operationType, message];
}
