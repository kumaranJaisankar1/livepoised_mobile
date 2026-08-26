import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/news_article.dart';

class NewsRepository {
  final Dio _dio;

  NewsRepository({Dio? dio}) : _dio = dio ?? DioClient().springBoot;

  /// Fetches trending SCI/rehab news from the Spring Boot backend. Degrades
  /// gracefully to an empty list on any failure (network, parse, or a
  /// malformed article in the response) — this is a nice-to-have dashboard
  /// section, not core functionality, so it should never block or crash the
  /// feed screen the way a failed post fetch would.
  /// [category] matches the backend's keyword-matched filters (`spinal`,
  /// `stroke`, `innovation`, `wellness`, or any custom keyword) — omit for
  /// the default aggregated/unified feed across all categories.
  Future<List<NewsArticle>> fetchTrendingNews({String? category}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.trendingNews,
        queryParameters: (category != null && category.isNotEmpty) ? {'category': category} : null,
      );
      final data = response.data;
      if (response.statusCode == 200 && data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) {
              try {
                return NewsArticle.fromJson(json);
              } catch (_) {
                return null;
              }
            })
            .whereType<NewsArticle>()
            .where((article) => article.url.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      print('[NewsRepository] Error fetching trending news: $e');
      return [];
    }
  }
}
