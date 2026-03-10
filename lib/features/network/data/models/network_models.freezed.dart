// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Connection _$ConnectionFromJson(Map<String, dynamic> json) {
  return _Connection.fromJson(json);
}

/// @nodoc
mixin _$Connection {
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'firstName')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'lastName')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'profileImage')
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get relationship =>
      throw _privateConstructorUsedError; // e.g., "Ally", "Parent", "Caregiver"
  @JsonKey(name: 'connectionType')
  String? get connectionType => throw _privateConstructorUsedError;

  /// Serializes this Connection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionCopyWith<Connection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionCopyWith<$Res> {
  factory $ConnectionCopyWith(
    Connection value,
    $Res Function(Connection) then,
  ) = _$ConnectionCopyWithImpl<$Res, Connection>;
  @useResult
  $Res call({
    String username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? imageUrl,
    String? relationship,
    @JsonKey(name: 'connectionType') String? connectionType,
  });
}

/// @nodoc
class _$ConnectionCopyWithImpl<$Res, $Val extends Connection>
    implements $ConnectionCopyWith<$Res> {
  _$ConnectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? imageUrl = freezed,
    Object? relationship = freezed,
    Object? connectionType = freezed,
  }) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            relationship: freezed == relationship
                ? _value.relationship
                : relationship // ignore: cast_nullable_to_non_nullable
                      as String?,
            connectionType: freezed == connectionType
                ? _value.connectionType
                : connectionType // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionImplCopyWith<$Res>
    implements $ConnectionCopyWith<$Res> {
  factory _$$ConnectionImplCopyWith(
    _$ConnectionImpl value,
    $Res Function(_$ConnectionImpl) then,
  ) = __$$ConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? imageUrl,
    String? relationship,
    @JsonKey(name: 'connectionType') String? connectionType,
  });
}

/// @nodoc
class __$$ConnectionImplCopyWithImpl<$Res>
    extends _$ConnectionCopyWithImpl<$Res, _$ConnectionImpl>
    implements _$$ConnectionImplCopyWith<$Res> {
  __$$ConnectionImplCopyWithImpl(
    _$ConnectionImpl _value,
    $Res Function(_$ConnectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? imageUrl = freezed,
    Object? relationship = freezed,
    Object? connectionType = freezed,
  }) {
    return _then(
      _$ConnectionImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        relationship: freezed == relationship
            ? _value.relationship
            : relationship // ignore: cast_nullable_to_non_nullable
                  as String?,
        connectionType: freezed == connectionType
            ? _value.connectionType
            : connectionType // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionImpl extends _Connection {
  const _$ConnectionImpl({
    required this.username,
    @JsonKey(name: 'firstName') this.firstName,
    @JsonKey(name: 'lastName') this.lastName,
    @JsonKey(name: 'profileImage') this.imageUrl,
    this.relationship,
    @JsonKey(name: 'connectionType') this.connectionType,
  }) : super._();

  factory _$ConnectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionImplFromJson(json);

  @override
  final String username;
  @override
  @JsonKey(name: 'firstName')
  final String? firstName;
  @override
  @JsonKey(name: 'lastName')
  final String? lastName;
  @override
  @JsonKey(name: 'profileImage')
  final String? imageUrl;
  @override
  final String? relationship;
  // e.g., "Ally", "Parent", "Caregiver"
  @override
  @JsonKey(name: 'connectionType')
  final String? connectionType;

  @override
  String toString() {
    return 'Connection(username: $username, firstName: $firstName, lastName: $lastName, imageUrl: $imageUrl, relationship: $relationship, connectionType: $connectionType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.relationship, relationship) ||
                other.relationship == relationship) &&
            (identical(other.connectionType, connectionType) ||
                other.connectionType == connectionType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    username,
    firstName,
    lastName,
    imageUrl,
    relationship,
    connectionType,
  );

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionImplCopyWith<_$ConnectionImpl> get copyWith =>
      __$$ConnectionImplCopyWithImpl<_$ConnectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionImplToJson(this);
  }
}

abstract class _Connection extends Connection {
  const factory _Connection({
    required final String username,
    @JsonKey(name: 'firstName') final String? firstName,
    @JsonKey(name: 'lastName') final String? lastName,
    @JsonKey(name: 'profileImage') final String? imageUrl,
    final String? relationship,
    @JsonKey(name: 'connectionType') final String? connectionType,
  }) = _$ConnectionImpl;
  const _Connection._() : super._();

  factory _Connection.fromJson(Map<String, dynamic> json) =
      _$ConnectionImpl.fromJson;

  @override
  String get username;
  @override
  @JsonKey(name: 'firstName')
  String? get firstName;
  @override
  @JsonKey(name: 'lastName')
  String? get lastName;
  @override
  @JsonKey(name: 'profileImage')
  String? get imageUrl;
  @override
  String? get relationship; // e.g., "Ally", "Parent", "Caregiver"
  @override
  @JsonKey(name: 'connectionType')
  String? get connectionType;

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionImplCopyWith<_$ConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NetworkRequest _$NetworkRequestFromJson(Map<String, dynamic> json) {
  return _NetworkRequest.fromJson(json);
}

/// @nodoc
mixin _$NetworkRequest {
  dynamic get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'linkId')
  dynamic get linkId => throw _privateConstructorUsedError; // For Supporter requests
  @JsonKey(name: 'mentorUsername')
  String? get mentorUsername => throw _privateConstructorUsedError; // For Ally requests
  @JsonKey(name: 'menteeUsername')
  String? get menteeUsername => throw _privateConstructorUsedError; // For Ally requests
  @JsonKey(name: 'username')
  String? get username => throw _privateConstructorUsedError; // For Supporter requests
  @JsonKey(name: 'firstName')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'lastName')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'profileImage')
  String? get senderImageUrl => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // "Ally" or "Supporter"
  String? get relationship => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this NetworkRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NetworkRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NetworkRequestCopyWith<NetworkRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkRequestCopyWith<$Res> {
  factory $NetworkRequestCopyWith(
    NetworkRequest value,
    $Res Function(NetworkRequest) then,
  ) = _$NetworkRequestCopyWithImpl<$Res, NetworkRequest>;
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'linkId') dynamic linkId,
    @JsonKey(name: 'mentorUsername') String? mentorUsername,
    @JsonKey(name: 'menteeUsername') String? menteeUsername,
    @JsonKey(name: 'username') String? username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? senderImageUrl,
    String type,
    String? relationship,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    String? status,
  });
}

/// @nodoc
class _$NetworkRequestCopyWithImpl<$Res, $Val extends NetworkRequest>
    implements $NetworkRequestCopyWith<$Res> {
  _$NetworkRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NetworkRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? linkId = freezed,
    Object? mentorUsername = freezed,
    Object? menteeUsername = freezed,
    Object? username = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? senderImageUrl = freezed,
    Object? type = null,
    Object? relationship = freezed,
    Object? createdAt = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            linkId: freezed == linkId
                ? _value.linkId
                : linkId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            mentorUsername: freezed == mentorUsername
                ? _value.mentorUsername
                : mentorUsername // ignore: cast_nullable_to_non_nullable
                      as String?,
            menteeUsername: freezed == menteeUsername
                ? _value.menteeUsername
                : menteeUsername // ignore: cast_nullable_to_non_nullable
                      as String?,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderImageUrl: freezed == senderImageUrl
                ? _value.senderImageUrl
                : senderImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            relationship: freezed == relationship
                ? _value.relationship
                : relationship // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkRequestImplCopyWith<$Res>
    implements $NetworkRequestCopyWith<$Res> {
  factory _$$NetworkRequestImplCopyWith(
    _$NetworkRequestImpl value,
    $Res Function(_$NetworkRequestImpl) then,
  ) = __$$NetworkRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'linkId') dynamic linkId,
    @JsonKey(name: 'mentorUsername') String? mentorUsername,
    @JsonKey(name: 'menteeUsername') String? menteeUsername,
    @JsonKey(name: 'username') String? username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? senderImageUrl,
    String type,
    String? relationship,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    String? status,
  });
}

/// @nodoc
class __$$NetworkRequestImplCopyWithImpl<$Res>
    extends _$NetworkRequestCopyWithImpl<$Res, _$NetworkRequestImpl>
    implements _$$NetworkRequestImplCopyWith<$Res> {
  __$$NetworkRequestImplCopyWithImpl(
    _$NetworkRequestImpl _value,
    $Res Function(_$NetworkRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NetworkRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? linkId = freezed,
    Object? mentorUsername = freezed,
    Object? menteeUsername = freezed,
    Object? username = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? senderImageUrl = freezed,
    Object? type = null,
    Object? relationship = freezed,
    Object? createdAt = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$NetworkRequestImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        linkId: freezed == linkId
            ? _value.linkId
            : linkId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        mentorUsername: freezed == mentorUsername
            ? _value.mentorUsername
            : mentorUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        menteeUsername: freezed == menteeUsername
            ? _value.menteeUsername
            : menteeUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderImageUrl: freezed == senderImageUrl
            ? _value.senderImageUrl
            : senderImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        relationship: freezed == relationship
            ? _value.relationship
            : relationship // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NetworkRequestImpl extends _NetworkRequest {
  const _$NetworkRequestImpl({
    required this.id,
    @JsonKey(name: 'linkId') this.linkId,
    @JsonKey(name: 'mentorUsername') this.mentorUsername,
    @JsonKey(name: 'menteeUsername') this.menteeUsername,
    @JsonKey(name: 'username') this.username,
    @JsonKey(name: 'firstName') this.firstName,
    @JsonKey(name: 'lastName') this.lastName,
    @JsonKey(name: 'profileImage') this.senderImageUrl,
    required this.type,
    this.relationship,
    @JsonKey(name: 'createdAt') this.createdAt,
    this.status,
  }) : super._();

  factory _$NetworkRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$NetworkRequestImplFromJson(json);

  @override
  final dynamic id;
  @override
  @JsonKey(name: 'linkId')
  final dynamic linkId;
  // For Supporter requests
  @override
  @JsonKey(name: 'mentorUsername')
  final String? mentorUsername;
  // For Ally requests
  @override
  @JsonKey(name: 'menteeUsername')
  final String? menteeUsername;
  // For Ally requests
  @override
  @JsonKey(name: 'username')
  final String? username;
  // For Supporter requests
  @override
  @JsonKey(name: 'firstName')
  final String? firstName;
  @override
  @JsonKey(name: 'lastName')
  final String? lastName;
  @override
  @JsonKey(name: 'profileImage')
  final String? senderImageUrl;
  @override
  final String type;
  // "Ally" or "Supporter"
  @override
  final String? relationship;
  @override
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @override
  final String? status;

  @override
  String toString() {
    return 'NetworkRequest(id: $id, linkId: $linkId, mentorUsername: $mentorUsername, menteeUsername: $menteeUsername, username: $username, firstName: $firstName, lastName: $lastName, senderImageUrl: $senderImageUrl, type: $type, relationship: $relationship, createdAt: $createdAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkRequestImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.linkId, linkId) &&
            (identical(other.mentorUsername, mentorUsername) ||
                other.mentorUsername == mentorUsername) &&
            (identical(other.menteeUsername, menteeUsername) ||
                other.menteeUsername == menteeUsername) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.senderImageUrl, senderImageUrl) ||
                other.senderImageUrl == senderImageUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.relationship, relationship) ||
                other.relationship == relationship) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(id),
    const DeepCollectionEquality().hash(linkId),
    mentorUsername,
    menteeUsername,
    username,
    firstName,
    lastName,
    senderImageUrl,
    type,
    relationship,
    createdAt,
    status,
  );

  /// Create a copy of NetworkRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkRequestImplCopyWith<_$NetworkRequestImpl> get copyWith =>
      __$$NetworkRequestImplCopyWithImpl<_$NetworkRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NetworkRequestImplToJson(this);
  }
}

abstract class _NetworkRequest extends NetworkRequest {
  const factory _NetworkRequest({
    required final dynamic id,
    @JsonKey(name: 'linkId') final dynamic linkId,
    @JsonKey(name: 'mentorUsername') final String? mentorUsername,
    @JsonKey(name: 'menteeUsername') final String? menteeUsername,
    @JsonKey(name: 'username') final String? username,
    @JsonKey(name: 'firstName') final String? firstName,
    @JsonKey(name: 'lastName') final String? lastName,
    @JsonKey(name: 'profileImage') final String? senderImageUrl,
    required final String type,
    final String? relationship,
    @JsonKey(name: 'createdAt') final DateTime? createdAt,
    final String? status,
  }) = _$NetworkRequestImpl;
  const _NetworkRequest._() : super._();

  factory _NetworkRequest.fromJson(Map<String, dynamic> json) =
      _$NetworkRequestImpl.fromJson;

  @override
  dynamic get id;
  @override
  @JsonKey(name: 'linkId')
  dynamic get linkId; // For Supporter requests
  @override
  @JsonKey(name: 'mentorUsername')
  String? get mentorUsername; // For Ally requests
  @override
  @JsonKey(name: 'menteeUsername')
  String? get menteeUsername; // For Ally requests
  @override
  @JsonKey(name: 'username')
  String? get username; // For Supporter requests
  @override
  @JsonKey(name: 'firstName')
  String? get firstName;
  @override
  @JsonKey(name: 'lastName')
  String? get lastName;
  @override
  @JsonKey(name: 'profileImage')
  String? get senderImageUrl;
  @override
  String get type; // "Ally" or "Supporter"
  @override
  String? get relationship;
  @override
  @JsonKey(name: 'createdAt')
  DateTime? get createdAt;
  @override
  String? get status;

  /// Create a copy of NetworkRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkRequestImplCopyWith<_$NetworkRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
