import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';
import '../../data/datasource/chat_service.dart';
import '../../data/datasource/chat_websocket_service.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_connection.dart';
import '../../data/models/inbox_item.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../notification/presentation/controllers/notification_controller.dart';
import 'chat_list_controller.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final ChatWebSocketService _wsService = Get.find<ChatWebSocketService>();
  final AuthController _authController = Get.find<AuthController>();

  final messages = <ChatMessage>[].obs;
  final isLoadingHistory = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final nextCursor = Rxn<dynamic>();
  final isOtherUserTyping = false.obs;

  final ScrollController scrollController = ScrollController();
  final inboxItem = Rxn<InboxItem>();

  Timer? _typingDebounceTimer;
  Timer? _peerTypingTimer;

  String? get currentUsername => _authController.userProfile.value?.username;

  String? get otherUsername {
    if (inboxItem.value != null) return inboxItem.value!.otherUsername;
    final args = Get.arguments;
    if (args is String) return args;
    if (args is ChatConnection) return args.username;
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is InboxItem) {
      inboxItem.value = args;
    } else if (args is ChatConnection) {
      inboxItem.value = InboxItem(
        otherUsername: args.username,
        otherUserFirstName: args.firstName,
        otherUserLastName: args.lastName,
        otherUserImageUrl: args.profileImage,
        timestamp: DateTime.now(),
      );
    } else if (args is String) {
      if (Get.isRegistered<ChatListController>()) {
        final existing = Get.find<ChatListController>().inboxItems.firstWhereOrNull((item) => item.otherUsername == args);
        if (existing != null) {
          inboxItem.value = existing;
        }
      }
    }

    final String? otherUser = otherUsername;
    if (otherUser != null && otherUser.isNotEmpty) {
      fetchHistory(otherUser);
      PushNotificationService.clearNotificationsForUser(otherUser);
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().markNotificationsAsReadForUser(otherUser);
      }
    }

    _wsService.messages.listen(onIncomingMessage);
    _wsService.rawMessages.listen(_handleRawSignal);

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      fetchMoreHistory();
    }
  }

  Future<void> fetchHistory(String otherUser) async {
    if (currentUsername == null) return;

    isLoadingHistory(true);
    hasMore.value = true;
    nextCursor.value = null;

    try {
      if (inboxItem.value == null || inboxItem.value?.otherUserImageUrl == null) {
        try {
          final connections = await _chatService.getConnections();
          final match = connections.firstWhereOrNull((c) => c.username == otherUser);
          if (match != null) {
            inboxItem.value = InboxItem(
              otherUsername: match.username,
              otherUserFirstName: match.firstName,
              otherUserLastName: match.lastName,
              otherUserImageUrl: match.profileImage,
              timestamp: DateTime.now(),
            );
          }
        } catch (_) {}
      }

      await _chatService.startInbox(otherUser, currentUsername!);
      final response = await _chatService.getChatHistory(currentUsername!, otherUser, limit: 30);

      // In reversed ListView: index 0 is newest (bottom), last index is oldest (top)
      // Response.messages is oldest-first batch from backend: [oldest ... newest]
      final reversedBatch = response.messages.reversed.toList();
      messages.assignAll(reversedBatch);

      hasMore.value = response.hasMore;
      nextCursor.value = response.nextCursor;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chat history');
    } finally {
      isLoadingHistory(false);
    }
  }

  Future<void> fetchMoreHistory() async {
    final String? otherUser = otherUsername;
    if (otherUser == null || currentUsername == null) return;
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore(true);

    try {
      // Use nextCursor if available; fallback to the oldest message's ID (last element in reversed messages)
      final cursor = nextCursor.value ?? (messages.isNotEmpty ? messages.last.id : null);
      if (cursor == null) {
        hasMore.value = false;
        return;
      }

      final response = await _chatService.getChatHistory(
        currentUsername!,
        otherUser,
        beforeId: cursor,
        limit: 30,
      );

      final olderBatchReversed = response.messages.reversed.toList();
      messages.addAll(olderBatchReversed);

      hasMore.value = response.hasMore;
      nextCursor.value = response.nextCursor;
    } catch (e) {
      print('ChatController: Error fetching more history: $e');
    } finally {
      isLoadingMore(false);
    }
  }

  void sendMessage(String content, String receiverUsername) {
    if (currentUsername == null) return;

    final tempMsg = ChatMessage(
      id: "temp-${DateTime.now().millisecondsSinceEpoch}",
      content: content,
      senderUsername: currentUsername!,
      receiverUsername: receiverUsername,
      timestamp: DateTime.now(),
      isOptimistic: true,
    );

    messages.insert(0, tempMsg);
    _refreshInbox();

    _wsService.sendMessage(content, receiverUsername);
    sendTypingStatus(false);
  }

  void onIncomingMessage(ChatMessage msg) {
    if (msg.content.trim().isEmpty) return;
    if (msg.senderUsername != otherUsername && msg.receiverUsername != otherUsername) {
      return;
    }

    final exactMatchIndex = messages.indexWhere((m) => m.id == msg.id);
    if (exactMatchIndex != -1) {
      messages[exactMatchIndex] = msg;
      _refreshInbox();
      return;
    }

    final optIndex = messages.indexWhere((m) =>
        m.isOptimistic &&
        m.id.startsWith('temp-') &&
        m.content == msg.content &&
        m.senderUsername == msg.senderUsername &&
        m.receiverUsername == msg.receiverUsername &&
        m.timestamp.difference(msg.timestamp).inSeconds.abs() <= 5);

    if (optIndex != -1) {
      messages[optIndex] = msg;
      _refreshInbox();
      return;
    }

    messages.insert(0, msg);
    _refreshInbox();
  }

  void onTextChanged(String text) {
    if (otherUsername == null) return;
    sendTypingStatus(text.trim().isNotEmpty);
  }

  void sendTypingStatus(bool isTyping) {
    final other = otherUsername;
    if (other == null) return;

    _typingDebounceTimer?.cancel();
    if (isTyping) {
      _wsService.sendTypingStatus(other, true);
      _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
        _wsService.sendTypingStatus(other, false);
      });
    } else {
      _wsService.sendTypingStatus(other, false);
    }
  }

  void _handleRawSignal(Map<String, dynamic> msg) {
    final type = msg['type'] as String?;
    if (type == 'typing') {
      final sender = msg['sender'] ?? msg['sender_username'];
      final isTyping = msg['is_typing'] as bool? ?? true;

      if (sender == otherUsername) {
        isOtherUserTyping.value = isTyping;
        _peerTypingTimer?.cancel();
        if (isTyping) {
          _peerTypingTimer = Timer(const Duration(seconds: 4), () {
            isOtherUserTyping.value = false;
          });
        }
      }
    }
  }

  void _refreshInbox() {
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().fetchInbox();
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _typingDebounceTimer?.cancel();
    _peerTypingTimer?.cancel();
    super.onClose();
  }
}
