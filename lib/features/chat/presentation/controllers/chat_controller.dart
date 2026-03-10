import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';
import '../../data/datasource/chat_service.dart';
import '../../data/datasource/chat_websocket_service.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_connection.dart';


class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final ChatWebSocketService _wsService = Get.find<ChatWebSocketService>();
  final AuthController _authController = Get.find<AuthController>();

  final messages = <ChatMessage>[].obs;
  final isLoadingHistory = false.obs;
  final ScrollController scrollController = ScrollController();
  final connection = Rxn<ChatConnection>();

  String? get currentUsername => _authController.userProfile.value?.username;

  String? get otherUsername {
    if (connection.value != null) return connection.value!.username;
    final args = Get.arguments;
    if (args is String) return args;
    return null;
  }

  Future<void> fetchHistory(String otherUser) async {
    if (currentUsername == null) return;
    
    isLoadingHistory(true);
    try {
      final history = await _chatService.getChatHistory(currentUsername!, otherUser);
      messages.assignAll(history.reversed); // Assuming history is chronologically ordered
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chat history');
    } finally {
      isLoadingHistory(false);
    }
  }

  void sendMessage(String content, String receiverUsername) {
    if (currentUsername == null) return;

    // 1. Create Optimistic Message
    final tempMsg = ChatMessage(
      id: "temp-${DateTime.now().millisecondsSinceEpoch}",
      content: content,
      senderUsername: currentUsername!,
      receiverUsername: receiverUsername,
      timestamp: DateTime.now(),
      isOptimistic: true,
    );
    
    // Insert at bottom (index 0 because ListView is reversed)
    messages.insert(0, tempMsg);

    // 2. Send via WebSocket
    _wsService.sendMessage(content, receiverUsername);
  }

  void onIncomingMessage(ChatMessage msg) {
    // Dedupe if it's an echo of our own message (same content and sender usually works for simple cases, 
    // but proper ID mapping is better if the server sends back an ID)
    // For now, if it's from me, we might already have it as optimistic
    if (msg.senderUsername == currentUsername) {
      // Find and replace optimistic message if needed, or just ignore if it's a simple echo
      final optIndex = messages.indexWhere((m) => m.isOptimistic && m.content == msg.content);
      if (optIndex != -1) {
        messages[optIndex] = msg.copyWith(isOptimistic: false);
        return;
      }
    }
    
    messages.insert(0, msg);
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ChatConnection) {
      connection.value = args;
    }

    final String? otherUser = otherUsername;
    if (otherUser != null) {
      fetchHistory(otherUser);
    }

    _wsService.messages.listen(onIncomingMessage);
  }
}
