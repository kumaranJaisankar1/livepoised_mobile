import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_models.freezed.dart';
part 'network_models.g.dart';

@freezed
class Connection with _$Connection {
  const Connection._();

  const factory Connection({
    required String username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? imageUrl,
    String? relationship, // e.g., "Ally", "Parent", "Caregiver"
    @JsonKey(name: 'connectionType') String? connectionType,
  }) = _Connection;

  String get name => '${firstName ?? ''} ${lastName ?? ''}'.trim().isEmpty 
      ? username 
      : '${firstName ?? ''} ${lastName ?? ''}'.trim();

  bool get isSupport => connectionType == 'CAREGIVER';
  bool get isAlly => connectionType == 'ALLY';

  factory Connection.fromJson(Map<String, dynamic> json) => _$ConnectionFromJson(json);
}

@freezed
class NetworkRequest with _$NetworkRequest {
  const NetworkRequest._();

  const factory NetworkRequest({
    required dynamic id,
    @JsonKey(name: 'linkId') dynamic linkId, // For Supporter requests
    @JsonKey(name: 'mentorUsername') String? mentorUsername, // For Ally requests
    @JsonKey(name: 'menteeUsername') String? menteeUsername, // For Ally requests
    @JsonKey(name: 'username') String? username, // For Supporter requests
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'preferredName') String? preferredName,
    @JsonKey(name: 'profileImage') String? senderImageUrl,
    required String type, // "Ally" or "Supporter"
    String? relationship,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    String? status,
  }) = _NetworkRequest;

  String get senderUsername => username ?? mentorUsername ?? menteeUsername ?? 'Unknown';
  
  String get name {
    if (preferredName != null && preferredName!.isNotEmpty) {
      return preferredName!;
    }
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return senderUsername;
  }

  factory NetworkRequest.fromJson(Map<String, dynamic> json) => _$NetworkRequestFromJson(json);
}

@freezed
class FindAllyRequest with _$FindAllyRequest {
  const factory FindAllyRequest({
    @JsonKey(name: 'user_id') required dynamic userId,
    required String username,
    required String query,
    @JsonKey(name: 'conditions') @Default('') String condition,
    @JsonKey(name: 'preferred_country') @Default('') String preferredCountry,
    @JsonKey(name: 'preferred_languages') @Default([]) List<String> preferredLanguages,
    @JsonKey(name: 'min_experience_years') @Default(0) int minExperienceYears,
    @JsonKey(name: 'live_experience_tags') @Default([]) List<String> liveExperienceTags,
    @JsonKey(name: 'offer_support', includeIfNull: false) bool? offerSupport,
    @JsonKey(name: 'top_k') @Default(5) int topK,
  }) = _FindAllyRequest;

  factory FindAllyRequest.fromJson(Map<String, dynamic> json) => _$FindAllyRequestFromJson(json);
}

@freezed
class AllyMatch with _$AllyMatch {
  const factory AllyMatch({
    @JsonKey(name: 'user_id') required int userId,
    required String username,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'match_confidence') required int matchConfidence,
    @JsonKey(name: 'connection_status') String? connectionStatus,
    @JsonKey(name: 'about_me') String? aboutMe,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
    @JsonKey(name: 'live_experience_tags') List<String>? liveExperienceTags,
  }) = _AllyMatch;

  factory AllyMatch.fromJson(Map<String, dynamic> json) => _$AllyMatchFromJson(json);
}
