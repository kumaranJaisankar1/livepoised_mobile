// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipientUsername')
  String get recipientUsername => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'senderUsername')
  String? get senderUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'referenceId')
  dynamic get referenceId => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;
  @JsonKey(name: 'createdAt')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
    NotificationModel value,
    $Res Function(NotificationModel) then,
  ) = _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'recipientUsername') String recipientUsername,
    String type,
    String message,
    @JsonKey(name: 'senderUsername') String? senderUsername,
    @JsonKey(name: 'referenceId') dynamic referenceId,
    bool read,
    @JsonKey(name: 'createdAt') DateTime createdAt,
  });
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipientUsername = null,
    Object? type = null,
    Object? message = null,
    Object? senderUsername = freezed,
    Object? referenceId = freezed,
    Object? read = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            recipientUsername: null == recipientUsername
                ? _value.recipientUsername
                : recipientUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            senderUsername: freezed == senderUsername
                ? _value.senderUsername
                : senderUsername // ignore: cast_nullable_to_non_nullable
                      as String?,
            referenceId: freezed == referenceId
                ? _value.referenceId
                : referenceId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            read: null == read
                ? _value.read
                : read // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(
    _$NotificationModelImpl value,
    $Res Function(_$NotificationModelImpl) then,
  ) = __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'recipientUsername') String recipientUsername,
    String type,
    String message,
    @JsonKey(name: 'senderUsername') String? senderUsername,
    @JsonKey(name: 'referenceId') dynamic referenceId,
    bool read,
    @JsonKey(name: 'createdAt') DateTime createdAt,
  });
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(
    _$NotificationModelImpl _value,
    $Res Function(_$NotificationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipientUsername = null,
    Object? type = null,
    Object? message = null,
    Object? senderUsername = freezed,
    Object? referenceId = freezed,
    Object? read = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$NotificationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        recipientUsername: null == recipientUsername
            ? _value.recipientUsername
            : recipientUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        senderUsername: freezed == senderUsername
            ? _value.senderUsername
            : senderUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        referenceId: freezed == referenceId
            ? _value.referenceId
            : referenceId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        read: null == read
            ? _value.read
            : read // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl extends _NotificationModel {
  const _$NotificationModelImpl({
    required this.id,
    @JsonKey(name: 'recipientUsername') required this.recipientUsername,
    required this.type,
    required this.message,
    @JsonKey(name: 'senderUsername') this.senderUsername,
    @JsonKey(name: 'referenceId') this.referenceId,
    this.read = false,
    @JsonKey(name: 'createdAt') required this.createdAt,
  }) : super._();

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'recipientUsername')
  final String recipientUsername;
  @override
  final String type;
  @override
  final String message;
  @override
  @JsonKey(name: 'senderUsername')
  final String? senderUsername;
  @override
  @JsonKey(name: 'referenceId')
  final dynamic referenceId;
  @override
  @JsonKey()
  final bool read;
  @override
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @override
  String toString() {
    return 'NotificationModel(id: $id, recipientUsername: $recipientUsername, type: $type, message: $message, senderUsername: $senderUsername, referenceId: $referenceId, read: $read, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipientUsername, recipientUsername) ||
                other.recipientUsername == recipientUsername) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.senderUsername, senderUsername) ||
                other.senderUsername == senderUsername) &&
            const DeepCollectionEquality().equals(
              other.referenceId,
              referenceId,
            ) &&
            (identical(other.read, read) || other.read == read) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    recipientUsername,
    type,
    message,
    senderUsername,
    const DeepCollectionEquality().hash(referenceId),
    read,
    createdAt,
  );

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(this);
  }
}

abstract class _NotificationModel extends NotificationModel {
  const factory _NotificationModel({
    required final int id,
    @JsonKey(name: 'recipientUsername') required final String recipientUsername,
    required final String type,
    required final String message,
    @JsonKey(name: 'senderUsername') final String? senderUsername,
    @JsonKey(name: 'referenceId') final dynamic referenceId,
    final bool read,
    @JsonKey(name: 'createdAt') required final DateTime createdAt,
  }) = _$NotificationModelImpl;
  const _NotificationModel._() : super._();

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'recipientUsername')
  String get recipientUsername;
  @override
  String get type;
  @override
  String get message;
  @override
  @JsonKey(name: 'senderUsername')
  String? get senderUsername;
  @override
  @JsonKey(name: 'referenceId')
  dynamic get referenceId;
  @override
  bool get read;
  @override
  @JsonKey(name: 'createdAt')
  DateTime get createdAt;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
