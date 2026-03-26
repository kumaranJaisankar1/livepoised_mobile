// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InboxItemImpl _$$InboxItemImplFromJson(Map<String, dynamic> json) =>
    _$InboxItemImpl(
      otherUsername: json['other_username'] as String,
      lastMessage: json['last_message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isEncrypted: json['is_encrypted'] as bool? ?? false,
      senderUsername: json['sender_username'] as String?,
      receiverUsername: json['receiver_username'] as String?,
      otherUserImageUrl: json['other_user_image_url'] as String?,
      otherUserFirstName: json['other_user_first_name'] as String?,
      otherUserLastName: json['other_user_last_name'] as String?,
    );

Map<String, dynamic> _$$InboxItemImplToJson(_$InboxItemImpl instance) =>
    <String, dynamic>{
      'other_username': instance.otherUsername,
      'last_message': instance.lastMessage,
      'timestamp': instance.timestamp.toIso8601String(),
      'is_encrypted': instance.isEncrypted,
      'sender_username': instance.senderUsername,
      'receiver_username': instance.receiverUsername,
      'other_user_image_url': instance.otherUserImageUrl,
      'other_user_first_name': instance.otherUserFirstName,
      'other_user_last_name': instance.otherUserLastName,
    };
