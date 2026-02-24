import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/storage/secure_storage_service.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final SecureStorageService _storage = SecureStorageService();

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool _isConnecting = false;

  Future<void> connect() async {
    if (_isConnecting || _channel != null) return;
    _isConnecting = true;

    final token = await _storage.getAccessToken();
    final wsUrl = '${dotenv.get('WS_URL')}?token=$token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _messageController.add(data);
        },
        onDone: () {
          _channel = null;
          _isConnecting = false;
          _reconnect();
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _channel = null;
          _isConnecting = false;
          _reconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      print('WebSocket Connection Exception: $e');
    }
  }

  void _reconnect() {
    Timer(const Duration(seconds: 5), () => connect());
  }

  void sendMessage(String text, String recipientId) {
    if (_channel != null) {
      _channel!.sink.add(
        jsonEncode({
          'type': 'message',
          'content': text,
          'recipient_id': recipientId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    }
  }

  void close() {
    _channel?.sink.close();
    _messageController.close();
  }
}
