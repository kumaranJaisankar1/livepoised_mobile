// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: _idFromJson(json['id']),
      senderUsername: json['sender_username'] as String,
      receiverUsername: json['receiver_username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isEncrypted: json['is_encrypted'] as bool? ?? false,
      isOptimistic: json['isOptimistic'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_username': instance.senderUsername,
      'receiver_username': instance.receiverUsername,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_encrypted': instance.isEncrypted,
      'isOptimistic': instance.isOptimistic,
    };
