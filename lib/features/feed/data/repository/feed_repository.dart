import 'package:dio/dio.dart';
import '../models/post.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class FeedRepository {
  final Dio _dio = DioClient().fastAPI;


  Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('/posts', queryParameters: {
        'page': page,
        'limit': limit,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Fetch Posts Error: $e');
      return [];
    }
  }

  Future<bool> createPost(String content, {List<String>? hashtags, String? category}) async {
    try {
      final response = await _dio.post('/posts', data: {
        'content': content,
        'hashtags': hashtags,
        'medicalCategory': category,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Create Post Error: $e');
      return false;
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      final response = await _dio.post(ApiEndpoints.likePost(postId));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
