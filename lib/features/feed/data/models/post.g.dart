// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  id: json['id'] as String,
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  authorAvatar: json['authorAvatar'] as String?,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  repliesCount: (json['repliesCount'] as num?)?.toInt() ?? 0,
  hashtags:
      (json['hashtags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  medicalCategory: json['medicalCategory'] as String?,
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'authorAvatar': instance.authorAvatar,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'likesCount': instance.likesCount,
      'repliesCount': instance.repliesCount,
      'hashtags': instance.hashtags,
      'medicalCategory': instance.medicalCategory,
      'isLiked': instance.isLiked,
    };
