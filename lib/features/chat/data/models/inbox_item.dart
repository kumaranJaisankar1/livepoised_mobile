import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbox_item.freezed.dart';
part 'inbox_item.g.dart';

@freezed
class InboxItem with _$InboxItem {
  const factory InboxItem({
    @JsonKey(name: 'other_username') required String otherUsername,
    @JsonKey(name: 'last_message') String? lastMessage,
    required DateTime timestamp,
    @JsonKey(name: 'is_encrypted') @Default(false) bool isEncrypted,
    @JsonKey(name: 'sender_username') String? senderUsername,
    @JsonKey(name: 'receiver_username') String? receiverUsername,
    @JsonKey(name: 'other_user_image_url') String? otherUserImageUrl,
    @JsonKey(name: 'other_user_first_name') String? otherUserFirstName,
    @JsonKey(name: 'other_user_last_name') String? otherUserLastName,
  }) = _InboxItem;

  factory InboxItem.fromJson(Map<String, dynamic> json) => _$InboxItemFromJson(json);
}
