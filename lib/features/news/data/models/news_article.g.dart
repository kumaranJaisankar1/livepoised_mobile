// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsArticleImpl _$$NewsArticleImplFromJson(Map<String, dynamic> json) =>
    _$NewsArticleImpl(
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String?,
      sourceName: json['sourceName'] as String? ?? 'Unknown Source',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$$NewsArticleImplToJson(_$NewsArticleImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'imageUrl': instance.imageUrl,
      'sourceName': instance.sourceName,
      'publishedAt': instance.publishedAt.toIso8601String(),
    };
