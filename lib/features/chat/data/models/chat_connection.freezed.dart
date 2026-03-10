// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatConnection _$ChatConnectionFromJson(Map<String, dynamic> json) {
  return _ChatConnection.fromJson(json);
}

/// @nodoc
mixin _$ChatConnection {
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'firstName')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'lastName')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'profileImage')
  String? get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'connectionType')
  String? get connectionType => throw _privateConstructorUsedError;
  @JsonKey(name: 'relationship')
  String? get relationship => throw _privateConstructorUsedError;

  /// Serializes this ChatConnection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatConnectionCopyWith<ChatConnection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatConnectionCopyWith<$Res> {
  factory $ChatConnectionCopyWith(
    ChatConnection value,
    $Res Function(ChatConnection) then,
  ) = _$ChatConnectionCopyWithImpl<$Res, ChatConnection>;
  @useResult
  $Res call({
    String username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? profileImage,
    @JsonKey(name: 'connectionType') String? connectionType,
    @JsonKey(name: 'relationship') String? relationship,
  });
}

/// @nodoc
class _$ChatConnectionCopyWithImpl<$Res, $Val extends ChatConnection>
    implements $ChatConnectionCopyWith<$Res> {
  _$ChatConnectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? profileImage = freezed,
    Object? connectionType = freezed,
    Object? relationship = freezed,
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
            profileImage: freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            connectionType: freezed == connectionType
                ? _value.connectionType
                : connectionType // ignore: cast_nullable_to_non_nullable
                      as String?,
            relationship: freezed == relationship
                ? _value.relationship
                : relationship // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatConnectionImplCopyWith<$Res>
    implements $ChatConnectionCopyWith<$Res> {
  factory _$$ChatConnectionImplCopyWith(
    _$ChatConnectionImpl value,
    $Res Function(_$ChatConnectionImpl) then,
  ) = __$$ChatConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? profileImage,
    @JsonKey(name: 'connectionType') String? connectionType,
    @JsonKey(name: 'relationship') String? relationship,
  });
}

/// @nodoc
class __$$ChatConnectionImplCopyWithImpl<$Res>
    extends _$ChatConnectionCopyWithImpl<$Res, _$ChatConnectionImpl>
    implements _$$ChatConnectionImplCopyWith<$Res> {
  __$$ChatConnectionImplCopyWithImpl(
    _$ChatConnectionImpl _value,
    $Res Function(_$ChatConnectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? profileImage = freezed,
    Object? connectionType = freezed,
    Object? relationship = freezed,
  }) {
    return _then(
      _$ChatConnectionImpl(
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
        profileImage: freezed == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        connectionType: freezed == connectionType
            ? _value.connectionType
            : connectionType // ignore: cast_nullable_to_non_nullable
                  as String?,
        relationship: freezed == relationship
            ? _value.relationship
            : relationship // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatConnectionImpl implements _ChatConnection {
  const _$ChatConnectionImpl({
    required this.username,
    @JsonKey(name: 'firstName') this.firstName,
    @JsonKey(name: 'lastName') this.lastName,
    @JsonKey(name: 'profileImage') this.profileImage,
    @JsonKey(name: 'connectionType') this.connectionType,
    @JsonKey(name: 'relationship') this.relationship,
  });

  factory _$ChatConnectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatConnectionImplFromJson(json);

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
  final String? profileImage;
  @override
  @JsonKey(name: 'connectionType')
  final String? connectionType;
  @override
  @JsonKey(name: 'relationship')
  final String? relationship;

  @override
  String toString() {
    return 'ChatConnection(username: $username, firstName: $firstName, lastName: $lastName, profileImage: $profileImage, connectionType: $connectionType, relationship: $relationship)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatConnectionImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.connectionType, connectionType) ||
                other.connectionType == connectionType) &&
            (identical(other.relationship, relationship) ||
                other.relationship == relationship));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    username,
    firstName,
    lastName,
    profileImage,
    connectionType,
    relationship,
  );

  /// Create a copy of ChatConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatConnectionImplCopyWith<_$ChatConnectionImpl> get copyWith =>
      __$$ChatConnectionImplCopyWithImpl<_$ChatConnectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatConnectionImplToJson(this);
  }
}

abstract class _ChatConnection implements ChatConnection {
  const factory _ChatConnection({
    required final String username,
    @JsonKey(name: 'firstName') final String? firstName,
    @JsonKey(name: 'lastName') final String? lastName,
    @JsonKey(name: 'profileImage') final String? profileImage,
    @JsonKey(name: 'connectionType') final String? connectionType,
    @JsonKey(name: 'relationship') final String? relationship,
  }) = _$ChatConnectionImpl;

  factory _ChatConnection.fromJson(Map<String, dynamic> json) =
      _$ChatConnectionImpl.fromJson;

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
  String? get profileImage;
  @override
  @JsonKey(name: 'connectionType')
  String? get connectionType;
  @override
  @JsonKey(name: 'relationship')
  String? get relationship;

  /// Create a copy of ChatConnection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatConnectionImplCopyWith<_$ChatConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
