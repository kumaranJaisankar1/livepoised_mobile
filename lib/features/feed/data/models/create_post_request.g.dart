// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreatePostRequestImpl _$$CreatePostRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreatePostRequestImpl(
  title: json['title'] as String,
  content: json['content'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  visibility: json['visibility'] as String? ?? "public",
  username: json['username'] as String,
  authorImageUrl: json['author_image_url'] as String?,
);

Map<String, dynamic> _$$CreatePostRequestImplToJson(
  _$CreatePostRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'tags': instance.tags,
  'visibility': instance.visibility,
  'username': instance.username,
  'author_image_url': instance.authorImageUrl,
};
