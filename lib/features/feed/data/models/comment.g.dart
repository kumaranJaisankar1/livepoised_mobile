// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'],
      text: json['text'] as String,
      authorName: json['author_name'] as String,
      authorUserId: json['author_user_id'] as String?,
      authorId: json['author_id'] as String?,
      authorImageUrl: json['author_image_url'] as String?,
      authorRole: json['author_role'] as String?,
      parentId: json['parent_id'],
      rootId: json['root_id'],
      postId: json['post_id'],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      likedBy:
          (json['liked_by'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isLiked: json['is_liked'] as bool? ?? false,
      childrenCount: (json['children_count'] as num?)?.toInt() ?? 0,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      depth: (json['depth'] as num?)?.toInt() ?? 0,
      path: json['path'] as String?,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'author_name': instance.authorName,
      'author_user_id': instance.authorUserId,
      'author_id': instance.authorId,
      'author_image_url': instance.authorImageUrl,
      'author_role': instance.authorRole,
      'parent_id': instance.parentId,
      'root_id': instance.rootId,
      'post_id': instance.postId,
      'likes': instance.likes,
      'liked_by': instance.likedBy,
      'is_liked': instance.isLiked,
      'children_count': instance.childrenCount,
      'children': instance.children,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'depth': instance.depth,
      'path': instance.path,
    };
