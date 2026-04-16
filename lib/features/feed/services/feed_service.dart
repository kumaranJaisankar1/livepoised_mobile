import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import 'package:livepoised_mobile/features/feed/data/models/post.dart';
import 'package:livepoised_mobile/features/feed/data/models/post_detail_response.dart';
import 'package:livepoised_mobile/features/feed/data/models/community_model.dart';
import 'package:livepoised_mobile/features/feed/data/models/create_post_request.dart';
import 'package:livepoised_mobile/core/network/dio_client.dart';
import 'package:livepoised_mobile/core/storage/secure_storage_service.dart';

class FeedService {
  final _dio = DioClient().fastAPI;
  final _storage = SecureStorageService();

  Future<List<Post>> getTrendingPosts() async {
    try {
      final response = await _dio.get(ApiEndpoints.trendingPosts);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching trending posts: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error parsing trending posts: $e');
      return [];
    }
  }

  Future<List<Post>> getLatestPosts() async {
    try {
      final response = await _dio.get(ApiEndpoints.latestPosts);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Post.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print('Error fetching latest posts: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error parsing latest posts: $e');
      return [];
    }
  }

  Future<PostDetailResponse?> getPostDetails(dynamic postId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.postDetails(postId),
        queryParameters: {
          'tree': 'true',
          'limit': 50,
          'skip': 0,
        },
      );
      
      if (response.statusCode == 200) {
        return PostDetailResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Error fetching post details: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error parsing post details: $e');
      return null;
    }
  }

  Future<bool> likePost(dynamic postId) async {
    final username = await _storage.getUsername();
    if (username == null) {
      debugPrint('FeedService: Error liking post: Username is null');
      return false;
    }

    final url = ApiEndpoints.likePost(postId);
    debugPrint('FeedService: Liking post: $postId for user: $username');
    debugPrint('FeedService: Hitting endpoint: $url');
    
    try {
      final response = await _dio.post(
        url,
        data: {'username': username},
      );
      debugPrint('FeedService: Like post response code: ${response.statusCode}');
      debugPrint('FeedService: Response data: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        debugPrint('FeedService: DioError liking post: ${e.message}');
        debugPrint('FeedService: DioError response: ${e.response?.data}');
      } else {
        debugPrint('FeedService: Unexpected error liking post: $e');
      }
      return false;
    }
  }

  Future<bool> createComment(dynamic postId, String text, {String? parentId}) async {
    final username = await _storage.getUsername();
    if (username == null) return false;

    try {
      final response = await _dio.post(
        ApiEndpoints.postComments(postId),
        data: {
          'text': text,
          'parent_id': parentId,
          'username': username,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating comment: $e');
      return false;
    }
  }

  Future<bool> likeComment(dynamic commentId) async {
    final username = await _storage.getUsername();
    if (username == null) return false;

    try {
      final response = await _dio.post(
        ApiEndpoints.likeComment(commentId),
        data: {'username': username},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error liking comment: $e');
      return false;
    }
  }

  Future<bool> deletePost(dynamic postId) async {
    final username = await _storage.getUsername();
    if (username == null) return false;

    try {
      final response = await _dio.delete(
        ApiEndpoints.postDetails(postId),
        data: {'username': username},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  Future<List<CommunityModel>> getCommunities() async {
    try {
      print('Fetching communities from: ${ApiEndpoints.communities}');
      final response = await _dio.get(ApiEndpoints.communities);
      print('Communities response status: ${response.statusCode}');
      print('Communities response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CommunityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching communities: $e');
      return [];
    }
  }

  Future<bool> createPost(dynamic communityId, CreatePostRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createPost(communityId),
        data: request.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  Future<bool> updatePost(dynamic postId, CreatePostRequest request) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.postDetails(postId),
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }
}

