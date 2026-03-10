// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatConnectionImpl _$$ChatConnectionImplFromJson(Map<String, dynamic> json) =>
    _$ChatConnectionImpl(
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profileImage: json['profileImage'] as String?,
      connectionType: json['connectionType'] as String?,
      relationship: json['relationship'] as String?,
    );

Map<String, dynamic> _$$ChatConnectionImplToJson(
  _$ChatConnectionImpl instance,
) => <String, dynamic>{
  'username': instance.username,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'profileImage': instance.profileImage,
  'connectionType': instance.connectionType,
  'relationship': instance.relationship,
};
