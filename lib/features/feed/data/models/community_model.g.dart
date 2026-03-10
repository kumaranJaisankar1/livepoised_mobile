// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommunityModelImpl _$$CommunityModelImplFromJson(Map<String, dynamic> json) =>
    _$CommunityModelImpl(
      id: json['id'],
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$CommunityModelImplToJson(
  _$CommunityModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'image_url': instance.imageUrl,
};
