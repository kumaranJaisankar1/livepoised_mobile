import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/auth_controller.dart';
import '../models/chat_message.dart';

class ChatWebSocketService extends GetxService {
  WebSocketChannel? _channel;
  final AuthController _authController = Get.find<AuthController>();

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messages => _messageController.stream;

  final _rawMessageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get rawMessages => _rawMessageController.stream;

  bool _isConnecting = false;

  @override
  void onInit() {
    super.onInit();
    // Re-connect when profile becomes available (e.g. after login)
    ever(_authController.userProfile, (profile) {
      print('ChatWebSocketService: Profile changed. Profile available: ${profile != null}');
      if (profile != null) {
        connect();
      } else {
        disconnect();
      }
    });

    // Check initial state if already logged in
    if (_authController.userProfile.value != null) {
      connect();
    }
  }

  Future<void> connect() async {
    final username = _authController.userProfile.value?.username;
    if (username == null) {
      print('ChatWebSocketService: Cannot connect, username is null');
      return;
    }
    
    if (_isConnecting || _channel != null) {
      print('ChatWebSocketService: Already connecting or connected');
      return;
    }
    
    _isConnecting = true;

    // Correct format based on guide: wss://{api-host}/chat/ws/{username}
    final wsUrl = '${ApiEndpoints.chatWsUrl}/chat/ws/$username';
    print('ChatWebSocketService: Attempting to connect to $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          print('ChatWebSocketService: Received message: $message');
          try {
            final data = jsonDecode(message);
            if (data is Map<String, dynamic>) {
              _rawMessageController.add(data);

              // Case 1: Standard JSON message
              final type = data['type'] as String?;
              final content = data['content'] as String?;

              if (content != null && content.trim().isNotEmpty && (type == null || type == 'chat' || !type.startsWith('call:'))) {
                final chatMsg = ChatMessage(
                  id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  senderUsername: data['sender_username'] ?? data['sender'] ?? '',
                  receiverUsername: data['receiver_username'] ?? data['receiver'] ?? '',
                  content: content.trim(),
                  timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
                );
                _messageController.add(chatMsg);
              }
            }
          } catch (e) {
            // Case 2: Handle plain text echo "You to {username}: {content}"
            final String msgStr = message.toString();
            if (msgStr.startsWith('You to ')) {
              final regExp = RegExp(r"You to ([^:]+): (.*)");
              final match = regExp.firstMatch(msgStr);
              if (match != null) {
                final recipient = match.group(1)?.trim() ?? '';
                final content = match.group(2)?.trim() ?? '';
                
                final chatMsg = ChatMessage(
                  id: "echo-${DateTime.now().millisecondsSinceEpoch}",
                  senderUsername: username, // It's "You", so it's me
                  receiverUsername: recipient,
                  content: content,
                  timestamp: DateTime.now(),
                );
                _messageController.add(chatMsg);
                return;
              }
            }
            print('ChatWebSocketService: Non-JSON message that could not be parsed: $message');
          }
        },
        onDone: () {
          print('ChatWebSocketService: WebSocket stream closed (onDone)');
          _channel = null;
          _isConnecting = false;
          _reconnect();
        },
        onError: (error) {
          print('ChatWebSocketService: Handled network disconnect: $error');
          _channel = null;
          _isConnecting = false;
          _reconnect();
        },
        cancelOnError: false,
      );
      print('ChatWebSocketService: Connection established successfully');
    } catch (e) {
      _isConnecting = false;
      print('ChatWebSocketService: Connection Exception: $e');
    }
  }

  void disconnect() {
    print('ChatWebSocketService: Disconnecting');
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _isConnecting = false;
  }

  void _reconnect() {
    if (_authController.userProfile.value != null && _channel == null && !_isConnecting) {
      Timer(const Duration(seconds: 3), () => connect());
    }
  }

  void sendMessage(String text, String recipientUsername) {
    if (_channel != null) {
      // Outgoing Format: { "receiver": "other_username", "content": "Your message here" }
      _channel!.sink.add(
        jsonEncode({
          'receiver': recipientUsername,
          'content': text,
        }),
      );
    } else {
      print('WebSocket not connected, cannot send message');
    }
  }

  void sendTypingStatus(String recipientUsername, bool isTyping) {
    if (_channel != null) {
      _channel!.sink.add(
        jsonEncode({
          'type': 'typing',
          'receiver': recipientUsername,
          'is_typing': isTyping,
        }),
      );
    }
  }

  void sendRaw(Map<String, dynamic> data) {
    if (_channel != null) {
      print('ChatWebSocketService: Sending raw frame: $data');
      _channel!.sink.add(jsonEncode(data));
    } else {
      print('ChatWebSocketService: WebSocket not connected, cannot send raw frame');
    }
  }

  bool get isConnected => _channel != null;

  /// Waits for auth to be ready and the socket to actually be dialed, up to
  /// [timeout]. Normally connect() is triggered reactively once
  /// AuthController.checkAuthStatus() populates userProfile — but a
  /// killed-app cold start that answers a call (via the native CallKit
  /// accept handle or the pending_call_action marker) can fire
  /// LiveKitService.acceptCall() before that async auth check has finished,
  /// while _channel is still null. sendRaw() silently no-ops in that case,
  /// so the backend never learns the call was accepted and the caller's
  /// device (web or another mobile device) is left showing "Calling..."
  /// forever even though this device already joined the LiveKit room.
  /// Call this before any call:* signal that the other party must receive.
  Future<bool> ensureConnected({Duration timeout = const Duration(seconds: 6)}) async {
    if (_channel != null) return true;
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (_authController.userProfile.value != null) {
        if (_channel == null && !_isConnecting) {
          await connect();
        }
        if (_channel != null) return true;
      }
      await Future.delayed(const Duration(milliseconds: 150));
    }
    return _channel != null;
  }

  @override
  void onClose() {
    _channel?.sink.close();
    _messageController.close();
    _rawMessageController.close();
    super.onClose();
  }
}
