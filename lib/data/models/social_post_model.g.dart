// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialPostModel _$SocialPostModelFromJson(Map<String, dynamic> json) =>
    SocialPostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      author: UserInfo.fromJson(json['author'] as Map<String, dynamic>),
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SocialPostModelToJson(SocialPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'content': instance.content,
      'author': instance.author,
      'mediaUrls': instance.mediaUrls,
      'tags': instance.tags,
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'isLiked': instance.isLiked,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  username: json['username'] as String?,
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'username': instance.username,
};

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['id'] as String,
  postId: json['postId'] as String,
  userId: json['userId'] as String,
  content: json['content'] as String,
  author: UserInfo.fromJson(json['author'] as Map<String, dynamic>),
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'userId': instance.userId,
      'content': instance.content,
      'author': instance.author,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
