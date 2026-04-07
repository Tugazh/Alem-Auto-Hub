import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'social_event.dart';
import 'social_state.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../core/error/result.dart';

/// BLoC для управления лентой сообщества.
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

  /// Загрузить ленту (стратегия cache-first).
  Future<void> _onLoadFeed(LoadFeed event, Emitter<SocialState> emit) async {
    _logger.i('Загрузка ленты сообщества...');
    emit(const SocialLoading());

    final result = await repository.getFeed();

    result.fold(
      (failure) {
        _logger.e('ERROR: Failed to load feed: ${failure.message}');
        emit(SocialError(failure));
      },
      (posts) {
        _logger.i('SUCCESS: Loaded ${posts.length} posts');
        emit(SocialFeedLoaded(posts: posts, isFromCache: result is Success));
      },
    );
  }

  /// Обновить ленту (принудительно из сети).
  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('Обновление ленты...');

    if (state is SocialFeedLoaded) {
      emit(const SocialLoading(isRefreshing: true));
    } else {
      emit(const SocialLoading());
    }

    final result = await repository.refreshFeed();

    result.fold(
      (failure) {
        _logger.e('ERROR: Failed to refresh: ${failure.message}');

        if (state is SocialFeedLoaded) {
          final currentState = state as SocialFeedLoaded;
          emit(SocialError(failure, cachedPosts: currentState.posts));
        } else {
          emit(SocialError(failure));
        }
      },
      (posts) {
        _logger.i('SUCCESS: Refreshed ${posts.length} posts');
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

  /// Отфильтровать ленту по типу.
  Future<void> _onFilterFeed(
    FilterFeed event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('Фильтрация ленты: ${event.filter}');
    emit(const SocialLoading());

    final result = await repository.getFeed(filter: event.filter);

    result.fold(
      (failure) {
        _logger.e('ERROR: Failed to filter: ${failure.message}');
        emit(SocialError(failure));
      },
      (posts) {
        _logger.i('SUCCESS: Filtered: ${posts.length} posts');
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

  /// Загрузить детали поста.
  Future<void> _onLoadPostDetails(
    LoadPostDetails event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('DATA: Loading post details: ${event.postId}');
    emit(const SocialLoading());

    final result = await repository.getPost(event.postId);

    result.fold(
      (failure) {
        _logger.e('ERROR: Failed to load post: ${failure.message}');
        emit(SocialError(failure));
      },
      (post) {
        _logger.i('SUCCESS: Post loaded: ${post.id}');
        emit(SocialPostDetailsLoaded(post));
      },
    );
  }

  /// Создать новый пост.
  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('Создание поста...');
    emit(const SocialOperationInProgress('create'));

    final result = await repository.createPost(
      content: event.content,
      mediaUrls: event.mediaUrls,
      tags: event.tags,
    );

    result.fold(
      (failure) {
        _logger.e('ERROR: Failed to create post: ${failure.message}');
        emit(SocialError(failure));
      },
      (post) {
        _logger.i('SUCCESS: Post created: ${post.id}');
        emit(const SocialOperationSuccess('create', 'Пост опубликован'));

        // Перезагрузка ленты.
        add(const LoadFeed());
      },
    );
  }

  /// Переключить лайк на посте.
  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<SocialState> emit,
  ) async {
    if (state is SocialFeedLoaded) {
      final currentState = state as SocialFeedLoaded;
      final likedIds = Set<String>.from(currentState.likedPostIds);
      final isLiked = likedIds.contains(event.postId);

      // Оптимистичное обновление.
      if (isLiked) {
        likedIds.remove(event.postId);
        _logger.i('Лайк снят: ${event.postId}');
      } else {
        likedIds.add(event.postId);
        _logger.i('Лайк поставлен: ${event.postId}');
      }

      emit(currentState.copyWith(likedPostIds: likedIds));

      // Отправка в бекенд.
      try {
        await repository.likePost(event.postId);
      } catch (e) {
        // Откат при ошибке.
        _logger.e('ERROR: Failed to toggle like: $e');
        if (isLiked) {
          likedIds.add(event.postId);
        } else {
          likedIds.remove(event.postId);
        }
        emit(currentState.copyWith(likedPostIds: likedIds));
      }
    }
  }

  /// Добавить комментарий к посту.
  Future<void> _onAddComment(
    AddComment event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('Добавление комментария к: ${event.postId}');
    emit(const SocialOperationInProgress('comment'));

    final result = await repository.addComment(
      postId: event.postId,
      content: event.content,
    );

    result.fold(
      (failure) {
        _logger.e('ERROR: Failed to add comment: ${failure.message}');
        emit(SocialError(failure));
      },
      (_) {
        _logger.i('SUCCESS: Comment added');
        emit(const SocialOperationSuccess('comment', 'Комментарий добавлен'));

        // Перезагрузка ленты.
        add(const LoadFeed());
      },
    );
  }

  /// Удалить пост.
  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<SocialState> emit,
  ) async {
    _logger.i('Удаление поста: ${event.postId}');
    emit(const SocialOperationInProgress('delete'));

    final result = await repository.deletePost(event.postId);

    result.fold(
      (failure) {
        _logger.e('ERROR: Failed to delete post: ${failure.message}');
        emit(SocialError(failure));
      },
      (_) {
        _logger.i('SUCCESS: Post deleted');
        emit(const SocialOperationSuccess('delete', 'Пост удален'));

        // Перезагрузка ленты.
        add(const LoadFeed());
      },
    );
  }
}
