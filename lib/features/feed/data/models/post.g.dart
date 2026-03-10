// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  id: json['id'],
  title: json['title'] as String,
  content: json['content'] as String,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  authorName: json['author_name'] as String,
  authorRole: json['author_role'] as String,
  authorImageUrl: json['author_image_url'] as String?,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  isLiked: json['is_liked'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  visibility: json['visibility'] as String?,
  communityId: json['community_id'],
  authorUserId: json['author_user_id'] as String?,
  likedBy:
      (json['liked_by'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'tags': instance.tags,
      'author_name': instance.authorName,
      'author_role': instance.authorRole,
      'author_image_url': instance.authorImageUrl,
      'likes': instance.likes,
      'comments_count': instance.commentsCount,
      'is_liked': instance.isLiked,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'visibility': instance.visibility,
      'community_id': instance.communityId,
      'author_user_id': instance.authorUserId,
      'liked_by': instance.likedBy,
    };
