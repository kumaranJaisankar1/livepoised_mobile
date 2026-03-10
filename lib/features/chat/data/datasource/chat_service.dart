import 'package:livepoised_mobile/core/network/dio_client.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import '../models/chat_connection.dart';
import '../models/chat_message.dart';

class ChatService {
  final _dioFastAPI = DioClient().fastAPI;
  final _dioSpringBoot = DioClient().springBoot;

  Future<List<ChatConnection>> getConnections() async {
    try {
      final response = await _dioSpringBoot.get(ApiEndpoints.connections);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatConnection.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching chat connections: $e');
      return [];
    }
  }

  Future<List<ChatMessage>> getChatHistory(String current, String other) async {
    try {
      final response = await _dioFastAPI.get(ApiEndpoints.getChatHistory(current, other));
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
    }
  }
}
