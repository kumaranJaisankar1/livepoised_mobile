import 'package:dio/dio.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import 'package:livepoised_mobile/core/network/dio_client.dart';
import '../data/models/network_models.dart';

class NetworkService {
  final _dio = DioClient().springBoot;

  Future<List<NetworkRequest>> getIncomingAllyRequests() async {
    try {
      final response = await _dio.get(ApiEndpoints.incomingAllyRequests);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          final Map<String, dynamic> mutableJson = Map<String, dynamic>.from(json);
          mutableJson['type'] = 'Ally';
          return NetworkRequest.fromJson(mutableJson);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching incoming ally requests: $e');
      return [];
    }
  }

  Future<List<NetworkRequest>> getOutgoingAllyRequests() async {
    try {
      final response = await _dio.get(ApiEndpoints.outgoingAllyRequests);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          final Map<String, dynamic> mutableJson = Map<String, dynamic>.from(json);
          mutableJson['type'] = 'Ally';
          return NetworkRequest.fromJson(mutableJson);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching outgoing ally requests: $e');
      return [];
    }
  }

  Future<bool> respondToAllyRequest(dynamic id, bool accept) async {
    try {
      final endpoint = accept 
          ? ApiEndpoints.acceptAllyRequest(id) 
          : ApiEndpoints.rejectAllyRequest(id);
      final response = await _dio.post(endpoint);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error responding to ally request: $e');
      return false;
    }
  }

  Future<List<NetworkRequest>> getPendingSupporterRequests() async {
    try {
      final response = await _dio.get(ApiEndpoints.pendingSupporterRequests);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          final Map<String, dynamic> mutableJson = Map<String, dynamic>.from(json);
          mutableJson['type'] = 'Supporter';
          mutableJson['id'] = mutableJson['linkId']; // Ensure id is present for UI
          return NetworkRequest.fromJson(mutableJson);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching pending supporter requests: $e');
      return [];
    }
  }

  Future<bool> respondToSupporterRequest(dynamic linkId, bool accept) async {
    try {
      final response = await _dio.post(ApiEndpoints.respondToSupporterRequest(linkId, accept));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error responding to supporter request: $e');
      return false;
    }
  }

  // --- Search and Request Creation ---

  Future<List<Connection>> searchUsers(String query) async {
    try {
      final response = await _dio.get(ApiEndpoints.searchCaregivers(query));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Map to Connection model for consistent UI display (using search results)
        return data.map((json) {
          final Map<String, dynamic> mutableJson = Map<String, dynamic>.from(json);
          // Ensure we map common fields correctly if DTO differs slightly
          return Connection.fromJson(mutableJson);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<bool> sendConnectionRequest(String username, String relationship, bool isAlly) async {
    try {
      // For now, using the caregiver request endpoint as a general connection request
      // We can differentiate later if the backend provides a separate mentoring request endpoint
      final response = await _dio.post(ApiEndpoints.sendCaregiverRequest(username, relationship));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sending connection request: $e');
      return false;
    }
  }

  // --- End Search ---

  Future<List<Connection>> getConnections() async {
    try {
      final response = await _dio.get(ApiEndpoints.connections);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Connection.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching connections: $e');
      return [];
    }
  }

  Future<List<Connection>> getPatientAllies() async {
    try {
      final response = await _dio.get(ApiEndpoints.patientAllies);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Connection.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching patient allies: $e');
      return [];
    }
  }
}
