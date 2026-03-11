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
      preferredName: json['preferredName'] as String?,
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
  'preferredName': instance.preferredName,
  'profileImage': instance.senderImageUrl,
  'type': instance.type,
  'relationship': instance.relationship,
  'createdAt': instance.createdAt?.toIso8601String(),
  'status': instance.status,
};

_$FindAllyRequestImpl _$$FindAllyRequestImplFromJson(
  Map<String, dynamic> json,
) => _$FindAllyRequestImpl(
  userId: json['user_id'],
  username: json['username'] as String,
  query: json['query'] as String,
  condition: json['conditions'] as String? ?? '',
  preferredCountry: json['preferred_country'] as String? ?? '',
  preferredLanguages:
      (json['preferred_languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  minExperienceYears: (json['min_experience_years'] as num?)?.toInt() ?? 0,
  liveExperienceTags:
      (json['live_experience_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  offerSupport: json['offer_support'] as bool?,
  topK: (json['top_k'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$$FindAllyRequestImplToJson(
  _$FindAllyRequestImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
  'query': instance.query,
  'conditions': instance.condition,
  'preferred_country': instance.preferredCountry,
  'preferred_languages': instance.preferredLanguages,
  'min_experience_years': instance.minExperienceYears,
  'live_experience_tags': instance.liveExperienceTags,
  if (instance.offerSupport case final value?) 'offer_support': value,
  'top_k': instance.topK,
};

_$AllyMatchImpl _$$AllyMatchImplFromJson(Map<String, dynamic> json) =>
    _$AllyMatchImpl(
      userId: (json['user_id'] as num).toInt(),
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      matchConfidence: (json['match_confidence'] as num).toInt(),
      connectionStatus: json['connection_status'] as String?,
      aboutMe: json['about_me'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      liveExperienceTags: (json['live_experience_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$AllyMatchImplToJson(_$AllyMatchImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'full_name': instance.fullName,
      'match_confidence': instance.matchConfidence,
      'connection_status': instance.connectionStatus,
      'about_me': instance.aboutMe,
      'profile_image_url': instance.profileImageUrl,
      'live_experience_tags': instance.liveExperienceTags,
    };
