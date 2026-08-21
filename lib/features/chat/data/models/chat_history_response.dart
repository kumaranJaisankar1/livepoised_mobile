import 'chat_message.dart';

class ChatHistoryResponse {
  final List<ChatMessage> messages;
  final dynamic nextCursor;
  final bool hasMore;

  ChatHistoryResponse({
    required this.messages,
    this.nextCursor,
    required this.hasMore,
  });

  factory ChatHistoryResponse.fromJson(dynamic json) {
    if (json is List) {
      final list = json.map((item) => ChatMessage.fromJson(item)).toList();
      return ChatHistoryResponse(
        messages: list,
        nextCursor: null,
        hasMore: false,
      );
    } else if (json is Map<String, dynamic>) {
      final rawList = (json['messages'] as List<dynamic>?) ?? [];
      final list = rawList.map((item) => ChatMessage.fromJson(item)).toList();
      return ChatHistoryResponse(
        messages: list,
        nextCursor: json['next_cursor'],
        hasMore: (json['has_more'] as bool?) ?? false,
      );
    }
    return ChatHistoryResponse(messages: [], nextCursor: null, hasMore: false);
  }
}
