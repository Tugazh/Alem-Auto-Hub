import 'package:json_annotation/json_annotation.dart';

part 'social_post_model.g.dart';

/// Social post model для /api/v1/social
@JsonSerializable()
class SocialPostModel {
  final String id;
  final String userId;
  final String content;
  final UserInfo author;
  final List<String> mediaUrls;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SocialPostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.author,
    this.mediaUrls = const [],
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) =>
      _$SocialPostModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocialPostModelToJson(this);

  SocialPostModel copyWith({
    String? id,
    String? userId,
    String? content,
    UserInfo? author,
    List<String>? mediaUrls,
    List<String>? tags,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      author: author ?? this.author,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      tags: tags ?? this.tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// User info для постов
@JsonSerializable()
class UserInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? username;

  const UserInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.username,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

/// Comment model
@JsonSerializable()
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final UserInfo author;
  final int likeCount;
  final DateTime? createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.author,
    this.likeCount = 0,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
