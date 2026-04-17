import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:livepoised_mobile/core/network/dio_client.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import '../models/profile_models.dart';

class ProfileService {
  final Dio _dio = DioClient().springBoot;

  Future<ProfileResponse> getProfileDetails(String username) async {
    try {
      final response = await _dio.get(ApiEndpoints.getProfile(username));
      return ProfileResponse.fromJson(response.data);
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserImage(String username) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getUserImage,
        queryParameters: {'username': username},
      );
      return response.data;
    } catch (e) {
      print('Error fetching user image: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String username, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateProfile(username),
        data: data,
      );
      return response.data;
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadImage(String username, File file, {Function(int, int)? onProgress}) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "username": username,
        "imageName": fileName,
        "image": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      
      final response = await _dio.post(
        ApiEndpoints.uploadImage,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
          responseType: ResponseType.plain,
        ),
        onSendProgress: onProgress,
      );

      final responseStr = response.data.toString();
      try {
        return json.decode(responseStr) as Map<String, dynamic>;
      } catch (e) {
        return {
          "status": "success",
          "message": responseStr,
        };
      }
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<List<ForumContribution>> getForumContributions(String userId) async {
    try {
      final response = await _dio.get(ApiEndpoints.getUserForumContributions(userId));
      return (response.data as List)
          .map((e) => ForumContribution.fromJson(e))
          .toList();
    } catch (e) {
      print('Error fetching forum contributions: $e');
      return [];
    }
  }

  // Note: Using fastAPI for chat sessions as specified in previous patterns, 
  // but following the provided endpoint which might be on Spring Boot.
  // I will use Spring Boot as requested in the guide.
  Future<List<ChatSession>> getChatSessions(String userId) async {
    try {
      final response = await _dio.get(ApiEndpoints.getUserChatSessions(userId));
      return (response.data as List).map((e) => ChatSession.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching chat sessions: $e');
      return [];
    }
  }

  Future<int> getConnectionsCount() async {
    try {
      final response = await _dio.get(ApiEndpoints.connections);
      if (response.data is List) {
        return (response.data as List).length;
      }
      return 0;
    } catch (e) {
      print('Error fetching connections: $e');
      return 0;
    }
  }

  Future<List<LinkedUserDTO>> searchCaregivers(String query) async {
    try {
      final response = await _dio.get(ApiEndpoints.searchCaregivers(query));
      return (response.data as List).map((e) => LinkedUserDTO.fromJson(e)).toList();
    } catch (e) {
      print('Error searching caregivers: $e');
      return [];
    }
  }

  Future<String> sendCaregiverRequest(String username, String relationship) async {
    try {
      final response = await _dio.post(ApiEndpoints.sendCaregiverRequest(username, relationship));
      return response.data;
    } catch (e) {
      print('Error sending caregiver request: $e');
      return 'Error sending request';
    }
  }

  Future<List<PendingCaregiverRequest>> getPendingRequests() async {
    try {
      final response = await _dio.get(ApiEndpoints.pendingSupporterRequests);
      return (response.data as List).map((e) => PendingCaregiverRequest.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching pending requests: $e');
      return [];
    }
  }

  Future<bool> respondToRequest(dynamic linkId, bool accept) async {
    try {
      await _dio.post(ApiEndpoints.respondToSupporterRequest(linkId, accept));
      return true;
    } catch (e) {
      print('Error responding to request: $e');
      return false;
    }
  }

  Future<List<Caregiver>> getPatientAllies() async {
    try {
      final response = await _dio.get(ApiEndpoints.patientAllies);
      return (response.data as List).map((e) => Caregiver.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching patient allies: $e');
      return [];
    }
  }

  Future<List<LinkedUserDTO>> getSuggestedConnections() async {
    try {
      final response = await _dio.get(ApiEndpoints.suggestedConnections);
      return (response.data as List).map((e) => LinkedUserDTO.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching suggested connections: $e');
      return [];
    }
  }
}
