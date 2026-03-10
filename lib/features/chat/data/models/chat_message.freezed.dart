// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  @JsonKey(fromJson: _idFromJson)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_username')
  String get senderUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_username')
  String get receiverUsername => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_encrypted')
  bool get isEncrypted => throw _privateConstructorUsedError;
  bool get isOptimistic => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _idFromJson) String id,
    @JsonKey(name: 'sender_username') String senderUsername,
    @JsonKey(name: 'receiver_username') String receiverUsername,
    String content,
    DateTime timestamp,
    @JsonKey(name: 'is_encrypted') bool isEncrypted,
    bool isOptimistic,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderUsername = null,
    Object? receiverUsername = null,
    Object? content = null,
    Object? timestamp = null,
    Object? isEncrypted = null,
    Object? isOptimistic = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            senderUsername: null == senderUsername
                ? _value.senderUsername
                : senderUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverUsername: null == receiverUsername
                ? _value.receiverUsername
                : receiverUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isEncrypted: null == isEncrypted
                ? _value.isEncrypted
                : isEncrypted // ignore: cast_nullable_to_non_nullable
                      as bool,
            isOptimistic: null == isOptimistic
                ? _value.isOptimistic
                : isOptimistic // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _idFromJson) String id,
    @JsonKey(name: 'sender_username') String senderUsername,
    @JsonKey(name: 'receiver_username') String receiverUsername,
    String content,
    DateTime timestamp,
    @JsonKey(name: 'is_encrypted') bool isEncrypted,
    bool isOptimistic,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderUsername = null,
    Object? receiverUsername = null,
    Object? content = null,
    Object? timestamp = null,
    Object? isEncrypted = null,
    Object? isOptimistic = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        senderUsername: null == senderUsername
            ? _value.senderUsername
            : senderUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverUsername: null == receiverUsername
            ? _value.receiverUsername
            : receiverUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isEncrypted: null == isEncrypted
            ? _value.isEncrypted
            : isEncrypted // ignore: cast_nullable_to_non_nullable
                  as bool,
        isOptimistic: null == isOptimistic
            ? _value.isOptimistic
            : isOptimistic // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl extends _ChatMessage {
  const _$ChatMessageImpl({
    @JsonKey(fromJson: _idFromJson) required this.id,
    @JsonKey(name: 'sender_username') required this.senderUsername,
    @JsonKey(name: 'receiver_username') required this.receiverUsername,
    required this.content,
    required this.timestamp,
    @JsonKey(name: 'is_encrypted') this.isEncrypted = false,
    this.isOptimistic = false,
  }) : super._();

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  @JsonKey(fromJson: _idFromJson)
  final String id;
  @override
  @JsonKey(name: 'sender_username')
  final String senderUsername;
  @override
  @JsonKey(name: 'receiver_username')
  final String receiverUsername;
  @override
  final String content;
  @override
  final DateTime timestamp;
  @override
  @JsonKey(name: 'is_encrypted')
  final bool isEncrypted;
  @override
  @JsonKey()
  final bool isOptimistic;

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderUsername: $senderUsername, receiverUsername: $receiverUsername, content: $content, timestamp: $timestamp, isEncrypted: $isEncrypted, isOptimistic: $isOptimistic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderUsername, senderUsername) ||
                other.senderUsername == senderUsername) &&
            (identical(other.receiverUsername, receiverUsername) ||
                other.receiverUsername == receiverUsername) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isEncrypted, isEncrypted) ||
                other.isEncrypted == isEncrypted) &&
            (identical(other.isOptimistic, isOptimistic) ||
                other.isOptimistic == isOptimistic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    senderUsername,
    receiverUsername,
    content,
    timestamp,
    isEncrypted,
    isOptimistic,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage extends ChatMessage {
  const factory _ChatMessage({
    @JsonKey(fromJson: _idFromJson) required final String id,
    @JsonKey(name: 'sender_username') required final String senderUsername,
    @JsonKey(name: 'receiver_username') required final String receiverUsername,
    required final String content,
    required final DateTime timestamp,
    @JsonKey(name: 'is_encrypted') final bool isEncrypted,
    final bool isOptimistic,
  }) = _$ChatMessageImpl;
  const _ChatMessage._() : super._();

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  @JsonKey(fromJson: _idFromJson)
  String get id;
  @override
  @JsonKey(name: 'sender_username')
  String get senderUsername;
  @override
  @JsonKey(name: 'receiver_username')
  String get receiverUsername;
  @override
  String get content;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(name: 'is_encrypted')
  bool get isEncrypted;
  @override
  bool get isOptimistic;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
