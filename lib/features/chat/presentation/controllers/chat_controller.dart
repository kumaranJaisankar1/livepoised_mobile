import 'package:get/get.dart';
import 'package:livepoised_mobile/features/chat/data/datasource/chat_websocket_service.dart';

class ChatController extends GetxController {
  final ChatWebSocketService _wsService = ChatWebSocketService();

  final messages = <Map<String, dynamic>>[].obs;
  final isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _wsService.connect();
    _wsService.messages.listen((msg) {
      messages.insert(0, msg);
    });
  }

  void sendMessage(String text, String recipientId) {
    _wsService.sendMessage(text, recipientId);
    // Optimistic UI update or wait for server ack
  }

  @override
  void onClose() {
    _wsService.close();
    super.onClose();
  }
}
