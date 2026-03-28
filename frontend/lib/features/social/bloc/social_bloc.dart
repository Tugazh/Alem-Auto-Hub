import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'social_event.dart';
import 'social_state.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../core/error/result.dart';

/// BLoC for managing social feed
class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialRepository repository;
  final Logger _logger = Logger();

  SocialBloc(this.repository) : super(const SocialInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<RefreshFeed>(_onRefreshFeed);
    on<FilterFeed>(_onFilterFeed);
    on<LoadPostDetails>(_onLoadPostDetails);
    on<CreatePost>(_onCreatePost);
    on<ToggleLike>(_onToggleLike);
    on<AddComment>(_onAddComment);
    on<DeletePost>(_onDeletePost);
  }

  /// Load feed (cache-first strategy)
  Future<void> _onLoadFeed(LoadFeed event, Emitter<SocialState> emit) async {
    _logger.i('📥 Loading social feed...');
    emit(const SocialLoading());

    final result = await repository.getFeed();

    result.fold(
      (failure) {
        _logger.e('❌ Failed to load feed: ${failure.message}');
        emit(SocialError(failure));
      },
      (posts) {
        _logger.i('✅ Loaded ${posts.length} posts');
        emit(SocialFeedLoaded(posts: posts, isFromCache: result is Success));
      },
    );
  }

  /// Refresh feed (force network)
  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('🔄 Refreshing feed...');

    if (state is SocialFeedLoaded) {
      emit(const SocialLoading(isRefreshing: true));
    } else {
      emit(const SocialLoading());
    }

    final result = await repository.refreshFeed();

    result.fold(
      (failure) {
        _logger.e('❌ Failed to refresh: ${failure.message}');

        if (state is SocialFeedLoaded) {
          final currentState = state as SocialFeedLoaded;
          emit(SocialError(failure, cachedPosts: currentState.posts));
        } else {
          emit(SocialError(failure));
        }
      },
      (posts) {
        _logger.i('✅ Refreshed ${posts.length} posts');
        final currentState = state;
        emit(
          SocialFeedLoaded(
            posts: posts,
            currentFilter: currentState is SocialFeedLoaded
                ? currentState.currentFilter
                : 'all',
            likedPostIds: currentState is SocialFeedLoaded
                ? currentState.likedPostIds
                : {},
          ),
        );
      },
    );
  }

  /// Filter feed by type
  Future<void> _onFilterFeed(
    FilterFeed event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('🔍 Filtering feed: ${event.filter}');
    emit(const SocialLoading());

    final result = await repository.getFeed(filter: event.filter);

    result.fold(
      (failure) {
        _logger.e('❌ Failed to filter: ${failure.message}');
        emit(SocialError(failure));
      },
      (posts) {
        _logger.i('✅ Filtered: ${posts.length} posts');
        final currentState = state;
        emit(
          SocialFeedLoaded(
            posts: posts,
            currentFilter: event.filter,
            likedPostIds: currentState is SocialFeedLoaded
                ? currentState.likedPostIds
                : {},
          ),
        );
      },
    );
  }

  /// Load post details
  Future<void> _onLoadPostDetails(
    LoadPostDetails event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('📦 Loading post details: ${event.postId}');
    emit(const SocialLoading());

    final result = await repository.getPost(event.postId);

    result.fold(
      (failure) {
        _logger.e('❌ Failed to load post: ${failure.message}');
        emit(SocialError(failure));
      },
      (post) {
        _logger.i('✅ Post loaded: ${post.id}');
        emit(SocialPostDetailsLoaded(post));
      },
    );
  }

  /// Create new post
  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('➕ Creating post...');
    emit(const SocialOperationInProgress('create'));

    final result = await repository.createPost(
      content: event.content,
      mediaUrls: event.mediaUrls,
      tags: event.tags,
    );

    result.fold(
      (failure) {
        _logger.e('❌ Failed to create post: ${failure.message}');
        emit(SocialError(failure));
      },
      (post) {
        _logger.i('✅ Post created: ${post.id}');
        emit(const SocialOperationSuccess('create', 'Пост опубликован'));

        // Reload feed
        add(const LoadFeed());
      },
    );
  }

  /// Toggle like on post
  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<SocialState> emit,
  ) async {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      final likedIds = Set<String>.from(currentState.likedPostIds);
      final isLiked = likedIds.contains(event.postId);

      // Optimistic update
      if (isLiked) {
        likedIds.remove(event.postId);
        _logger.i('💔 Unliked: ${event.postId}');
      } else {
        likedIds.add(event.postId);
        _logger.i('❤️ Liked: ${event.postId}');
      }

      emit(currentState.copyWith(likedPostIds: likedIds));

      // Send to backend
      try {
        await repository.likePost(event.postId);
      } catch (e) {
        // Revert on error
        _logger.e('❌ Failed to toggle like: $e');
        if (isLiked) {
          likedIds.add(event.postId);
        } else {
          likedIds.remove(event.postId);
        }
        emit(currentState.copyWith(likedPostIds: likedIds));
      }
    }
  }

  /// Add comment to post
  Future<void> _onAddComment(
    AddComment event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('💬 Adding comment to: ${event.postId}');
    emit(const SocialOperationInProgress('comment'));

    final result = await repository.addComment(
      postId: event.postId,
      content: event.content,
    );

    result.fold(
      (failure) {
        _logger.e('❌ Failed to add comment: ${failure.message}');
        emit(SocialError(failure));
      },
      (_) {
        _logger.i('✅ Comment added');
        emit(const SocialOperationSuccess('comment', 'Комментарий добавлен'));

        // Reload feed
        add(const LoadFeed());
      },
    );
  }

  /// Delete post
  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('🗑️ Deleting post: ${event.postId}');
    emit(const SocialOperationInProgress('delete'));

    final result = await repository.deletePost(event.postId);

    result.fold(
      (failure) {
        _logger.e('❌ Failed to delete post: ${failure.message}');
        emit(SocialError(failure));
      },
      (_) {
        _logger.i('✅ Post deleted');
        emit(const SocialOperationSuccess('delete', 'Пост удален'));

        // Reload feed
        add(const LoadFeed());
      },
    );
  }
}
