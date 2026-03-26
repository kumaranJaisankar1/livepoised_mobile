import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';
import '../../data/datasource/chat_service.dart';
import '../../data/datasource/chat_websocket_service.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/inbox_item.dart';
import 'chat_list_controller.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final ChatWebSocketService _wsService = Get.find<ChatWebSocketService>();
  final AuthController _authController = Get.find<AuthController>();

  final messages = <ChatMessage>[].obs;
  final isLoadingHistory = false.obs;
  final ScrollController scrollController = ScrollController();
  final inboxItem = Rxn<InboxItem>();

  String? get currentUsername => _authController.userProfile.value?.username;

  String? get otherUsername {
    if (inboxItem.value != null) return inboxItem.value!.otherUsername;
    final args = Get.arguments;
    if (args is String) return args;
    return null;
  }

  Future<void> fetchHistory(String otherUser) async {
    if (currentUsername == null) return;
    
    isLoadingHistory(true);
    try {
      // 1. Initialize inbox chat first
      await _chatService.startInbox(otherUser, currentUsername!);
      
      // 2. Fetch history
      final history = await _chatService.getChatHistory(currentUsername!, otherUser);
      
      // Optional: merge logic could go here if WebSocket messages arrived while fetching
      // but simpler to just assign and dedup any newly arrived via WebSocket Stream
      messages.assignAll(history.reversed);
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
    _refreshInbox();

    // 2. Send via WebSocket
    _wsService.sendMessage(content, receiverUsername);
  }

  void onIncomingMessage(ChatMessage msg) {
    // Only process messages for the currently open chat
    if (msg.senderUsername != otherUsername && msg.receiverUsername != otherUsername) {
      return;
    }

    // Deduplication Logic
    // Exact ID Match
    final exactMatchIndex = messages.indexWhere((m) => m.id == msg.id);
    if (exactMatchIndex != -1) {
      messages[exactMatchIndex] = msg;
      _refreshInbox();
      return;
    }

    // Content + Sender + Receiver + Time Match for Temp Messages
    final optIndex = messages.indexWhere((m) => 
      m.isOptimistic && 
      m.id.startsWith('temp-') &&
      m.content == msg.content && 
      m.senderUsername == msg.senderUsername && 
      m.receiverUsername == msg.receiverUsername &&
      m.timestamp.difference(msg.timestamp).inSeconds.abs() <= 5
    );
    
    if (optIndex != -1) {
      messages[optIndex] = msg;
      _refreshInbox();
      return;
    }
    
    // No match found, append to history
    messages.insert(0, msg);
    _refreshInbox();
  }

  void _refreshInbox() {
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().fetchInbox();
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is InboxItem) {
      inboxItem.value = args;
    }

    final String? otherUser = otherUsername;
    if (otherUser != null) {
      fetchHistory(otherUser);
    }

    _wsService.messages.listen(onIncomingMessage);
  }
}
