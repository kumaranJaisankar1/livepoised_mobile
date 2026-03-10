import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    @JsonKey(fromJson: _idFromJson) required String id,
    @JsonKey(name: 'sender_username') required String senderUsername,
    @JsonKey(name: 'receiver_username') required String receiverUsername,
    required String content,
    required DateTime timestamp,
    @JsonKey(name: 'is_encrypted') @Default(false) bool isEncrypted,
    @Default(false) bool isOptimistic,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  bool isMe(String currentUsername) => senderUsername == currentUsername;
}

String _idFromJson(dynamic id) => id?.toString() ?? '';
