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
    // ApiEndpoints.chatWsUrl is currently "wss://livepoised.vannadev.com/fastapi"
    final wsUrl = '${ApiEndpoints.chatWsUrl}/chat/ws/$username';
    print('ChatWebSocketService: Attempting to connect to $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          print('ChatWebSocketService: Received message: $message');
          try {
            final data = jsonDecode(message);
            // Case 1: Standard JSON message
            final chatMsg = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderUsername: data['sender_username'] ?? '',
              receiverUsername: data['receiver_username'] ?? '',
              content: data['content'] ?? '',
              timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
            );
            _messageController.add(chatMsg);
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
          print('ChatWebSocketService: WebSocket Error: $error');
          _channel = null;
          _isConnecting = false;
          _reconnect();
        },
      );
      print('ChatWebSocketService: Connection established successfully');
    } catch (e) {
      _isConnecting = false;
      print('ChatWebSocketService: Connection Exception: $e');
    }
  }

  void disconnect() {
    print('ChatWebSocketService: Disconnecting');
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
  }

  void _reconnect() {
    Timer(const Duration(seconds: 5), () => connect());
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

  @override
  void onClose() {
    _channel?.sink.close();
    _messageController.close();
    super.onClose();
  }
}
