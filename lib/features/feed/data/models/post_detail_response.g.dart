// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostDetailResponseImpl _$$PostDetailResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PostDetailResponseImpl(
  post: Post.fromJson(json['post'] as Map<String, dynamic>),
  commentsTree:
      (json['comments_tree'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$PostDetailResponseImplToJson(
  _$PostDetailResponseImpl instance,
) => <String, dynamic>{
  'post': instance.post,
  'comments_tree': instance.commentsTree,
};
