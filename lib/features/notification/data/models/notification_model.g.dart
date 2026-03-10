// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: (json['id'] as num).toInt(),
  recipientUsername: json['recipientUsername'] as String,
  type: json['type'] as String,
  message: json['message'] as String,
  senderUsername: json['senderUsername'] as String?,
  referenceId: json['referenceId'],
  read: json['read'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipientUsername': instance.recipientUsername,
  'type': instance.type,
  'message': instance.message,
  'senderUsername': instance.senderUsername,
  'referenceId': instance.referenceId,
  'read': instance.read,
  'createdAt': instance.createdAt.toIso8601String(),
};
