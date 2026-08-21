# LivePoised Mobile — Chat Feature Enhancement & Optimization Plan

> **App**: `livepoised_mobile` (Flutter / Dart)  
> **Goal**: Port and adapt the advanced web chat optimizations (infinite cursor scrolling, optimistic inbox mutations, resilient WebSocket handling) to Flutter for a native WhatsApp/Instagram-like experience.  
> **Updated**: 2026-08-20  

---

## 1. Feature Optimization Summary

To match the performance and seamless user experience of the `livepoisedux` web application, the mobile app needs to implement three key optimizations:

1. **Cursor-Based Infinite Scroll with Jump Prevention**: Loading historical messages on scroll using a database cursor, while maintaining the user's visual scroll position.
2. **Optimistic Local Inbox Cache Updates**: Bumping active conversation threads to the top and updating last-message previews instantly in state management, with **zero HTTP re-fetch requests** during active chats.
3. **Resilient WebSocket Lifecycle Handling**: Automatic ping/pong heartbeats, exponential backoff reconnects, and app state lifecycle restoration to recover connections instantly.

---

## 2. Cursor-Based Infinite Scroll (ListView Optimization)

On web, we used TanStack Query `useInfiniteQuery` and measured scroll height delta during renders. In Flutter, we achieve this by controlling the scroll offset and viewport of `ScrollController`.

### 2.1 The Prepending Jump Problem
When new items are inserted at index `0` (top) of a traditional top-down scroll list, the viewport shifts, causing the scroll position to "jump". 

### 2.2 Flutter Solution: Reversed ListView & Bottom-Up Rendering
By setting `reverse: true` on `ListView.builder` and loading older messages by appending them to the list, Flutter natively manages scroll offsets correctly when prepending items.

```dart
// lib/features/chat/presentation/views/chat_window_view.dart
class ChatWindowView extends StatefulWidget {
  const ChatWindowView({super.key});

  @override
  State<ChatWindowView> createState() => _ChatWindowViewState();
}

class _ChatWindowViewState extends State<ChatWindowView> {
  final ScrollController _scrollController = ScrollController();
  final ChatController _chatController = Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // In a reversed list, maxScrollExtent is the TOP of the conversation (older messages)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_chatController.hasMore.value && !_chatController.isLoadingMore.value) {
        _chatController.loadOlderMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = _chatController.messages;
      return ListView.builder(
        controller: _scrollController,
        reverse: true, // Key: Keeps latest messages at the bottom, loads older messages towards maxScrollExtent
        itemCount: messages.length + (_chatController.isLoadingMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == messages.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final msg = messages[index];
          return ChatBubble(message: msg);
        },
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 2.3 Paginated Repository Request
Calls the FastAPI backend cursor endpoint:
`GET /chat/history/{user1}/{user2}?before_id={oldest_message_id}&limit=30`

---

## 3. Real-Time Optimistic Inbox Cache Mutation

Every time a message is sent or received, we must update the conversation list (inbox) **optimistically in memory** and move the thread to the top, rather than calling the `GET /chat/inbox` API over the network.

### 3.1 Local State Controller Implementation

```dart
// lib/features/chat/presentation/controllers/inbox_controller.dart
import 'package:get/get.dart';
import '../../domain/models/inbox_item.dart';
import '../../domain/models/chat_message.dart';

class InboxController extends GetxController {
  final RxList<InboxItem> inboxList = <InboxItem>[].obs;
  final RxBool isLoading = false.obs;

  // ── Optimistic Local Update (0 HTTP Requests) ─────────────────────
  void updateInboxItemOptimistically(ChatMessage msg, String currentUsername) {
    final String otherUser = msg.senderUsername.toLowerCase() == currentUsername.toLowerCase()
        ? msg.receiverUsername
        : msg.senderUsername;

    // Find if thread exists
    final index = inboxList.indexWhere(
      (item) => item.otherUsername.toLowerCase() == otherUser.toLowerCase()
    );

    if (index != -1) {
      // 1. Extract and update existing item
      final existingItem = inboxList[index];
      final updatedItem = existingItem.copyWith(
        lastMessage: msg.content,
        timestamp: msg.timestamp,
        senderUsername: msg.senderUsername,
        receiverUsername: msg.receiverUsername,
      );

      // 2. Remove from old position and prepend to index 0 (Top)
      inboxList.removeAt(index);
      inboxList.insert(0, updatedItem);
    } else {
      // 3. Thread doesn't exist (new chat initiated) -> Prepend synthetic item
      final newItem = InboxItem(
        otherUsername: otherUser,
        lastMessage: msg.content,
        timestamp: msg.timestamp,
        senderUsername: msg.senderUsername,
        receiverUsername: msg.receiverUsername,
        otherUserImageUrl: '',
        otherUserFirstName: otherUser,
        otherUserLastName: '',
        isEncrypted: msg.isEncrypted,
      );
      inboxList.insert(0, newItem);
    }
  }
}
```

---

## 4. Resilient WebSocket Lifecycle Handling

Mobile devices frequently undergo network switches (WiFi to Cellular) and app pause/resume cycles. The WebSocket manager must handle these events gracefully.

### 4.1 Reconnection & Lifecycle Observer

```dart
// lib/features/chat/data/datasource/chat_websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';

class ChatWebSocketService extends GetxService with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  bool _isExplicitClosed = false;
  final String username;

  ChatWebSocketService(this.username);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // Listen for App pause/resume
    connect();
  }

  void connect() {
    if (_isExplicitClosed) return;
    
    final wsUrl = Uri.parse("ws://10.0.2.2:8000/chat/ws/$username");
    
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _startHeartbeat();
      _reconnectAttempts = 0;
      
      _channel!.stream.listen(
        (data) => _handleIncoming(data),
        onDone: () => _handleReconnect(),
        onError: (_) => _handleReconnect(),
      );
    } catch (_) {
      _handleReconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      sendRaw({'type': 'ping'}); // Keeps FastAPI / Nginx connection alive
    });
  }

  void _handleReconnect() {
    _heartbeatTimer?.cancel();
    if (_isExplicitClosed) return;

    final backoffSeconds = [1, 2, 4, 8, 10];
    final delay = backoffSeconds[_reconnectAttempts < 5 ? _reconnectAttempts : 4];
    _reconnectAttempts++;

    Timer(Duration(seconds: delay), () {
      connect();
    });
  }

  // ── App Lifecycle Observer (Foreground Resume Trigger) ───────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reconnect instantly when app is brought back to foreground
      if (_channel == null || _reconnectAttempts > 0) {
        print("[WS] App resumed. Instantly triggering connection recovery...");
        connect();
      }
    }
  }

  void sendRaw(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  @override
  void onClose() {
    _isExplicitClosed = true;
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
```

---

## 5. Emoji Picker Popover in Chat Input

In Flutter, standard keyboard height and layout constraints require rendering the emoji picker cleanly inside a bottom sheet or a toggleable keyboard-height matching container.

### 5.1 Keyboard-Emoji Switcher Layout
Use a simple GridView containing emojis. Load categories from a configuration constant file:

```dart
// lib/features/chat/presentation/widgets/emoji_picker.dart
class EmojiPickerSheet extends StatelessWidget {
  final Function(String) onEmojiSelected;
  const EmojiPickerSheet({super.key, required this.onEmojiSelected});

  static const List<String> smileys = ["😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: Theme.of(context).cardColor,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemCount: smileys.length,
        itemBuilder: (context, index) {
          final emoji = smileys[index];
          return GestureDetector(
            onTap: () => onEmojiSelected(emoji),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    );
  }
}
```

---

## 6. Mobile Optimization Checklist

- [ ] Configure Flutter `ListView.builder` with `reverse: true` for older message loading.
- [ ] Connect `ScrollController` listener to detect scroll to top boundaries.
- [ ] Implement local `inboxList` mutation using Riverpod / GetX in `InboxController`.
- [ ] Implement `WidgetsBindingObserver` in the WebSocket service to monitor app lifecycle states.
- [ ] Add the 25-second WebSocket ping heartbeat loop in Dart.
- [ ] Implement bottom-sheet Emoji Picker.
