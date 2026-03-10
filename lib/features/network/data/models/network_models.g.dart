// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConnectionImpl _$$ConnectionImplFromJson(Map<String, dynamic> json) =>
    _$ConnectionImpl(
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      imageUrl: json['profileImage'] as String?,
      relationship: json['relationship'] as String?,
      connectionType: json['connectionType'] as String?,
    );

Map<String, dynamic> _$$ConnectionImplToJson(_$ConnectionImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profileImage': instance.imageUrl,
      'relationship': instance.relationship,
      'connectionType': instance.connectionType,
    };

_$NetworkRequestImpl _$$NetworkRequestImplFromJson(Map<String, dynamic> json) =>
    _$NetworkRequestImpl(
      id: json['id'],
      linkId: json['linkId'],
      mentorUsername: json['mentorUsername'] as String?,
      menteeUsername: json['menteeUsername'] as String?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      senderImageUrl: json['profileImage'] as String?,
      type: json['type'] as String,
      relationship: json['relationship'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$NetworkRequestImplToJson(
  _$NetworkRequestImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'linkId': instance.linkId,
  'mentorUsername': instance.mentorUsername,
  'menteeUsername': instance.menteeUsername,
  'username': instance.username,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'profileImage': instance.senderImageUrl,
  'type': instance.type,
  'relationship': instance.relationship,
  'createdAt': instance.createdAt?.toIso8601String(),
  'status': instance.status,
};
