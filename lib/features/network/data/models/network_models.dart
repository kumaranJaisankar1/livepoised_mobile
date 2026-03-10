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
    @JsonKey(name: 'profileImage') String? senderImageUrl,
    required String type, // "Ally" or "Supporter"
    String? relationship,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    String? status,
  }) = _NetworkRequest;

  String get senderUsername => username ?? mentorUsername ?? menteeUsername ?? 'Unknown';
  
  String get name {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return senderUsername;
  }

  factory NetworkRequest.fromJson(Map<String, dynamic> json) => _$NetworkRequestFromJson(json);
}
