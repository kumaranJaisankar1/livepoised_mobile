import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_article.freezed.dart';
part 'news_article.g.dart';

@freezed
class NewsArticle with _$NewsArticle {
  const factory NewsArticle({
    required String title,
    @Default('') String description,
    required String url,
    @JsonKey(name: 'imageUrl') String? imageUrl,
    @JsonKey(name: 'sourceName') @Default('Unknown Source') String sourceName,
    @JsonKey(name: 'publishedAt') required DateTime publishedAt,
  }) = _NewsArticle;

  factory NewsArticle.fromJson(Map<String, dynamic> json) => _$NewsArticleFromJson(json);
}
