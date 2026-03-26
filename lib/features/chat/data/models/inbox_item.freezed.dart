// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InboxItem _$InboxItemFromJson(Map<String, dynamic> json) {
  return _InboxItem.fromJson(json);
}

/// @nodoc
mixin _$InboxItem {
  @JsonKey(name: 'other_username')
  String get otherUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message')
  String? get lastMessage => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_encrypted')
  bool get isEncrypted => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_username')
  String? get senderUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_username')
  String? get receiverUsername => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_user_image_url')
  String? get otherUserImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_user_first_name')
  String? get otherUserFirstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_user_last_name')
  String? get otherUserLastName => throw _privateConstructorUsedError;

  /// Serializes this InboxItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InboxItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InboxItemCopyWith<InboxItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InboxItemCopyWith<$Res> {
  factory $InboxItemCopyWith(InboxItem value, $Res Function(InboxItem) then) =
      _$InboxItemCopyWithImpl<$Res, InboxItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'other_username') String otherUsername,
    @JsonKey(name: 'last_message') String? lastMessage,
    DateTime timestamp,
    @JsonKey(name: 'is_encrypted') bool isEncrypted,
    @JsonKey(name: 'sender_username') String? senderUsername,
    @JsonKey(name: 'receiver_username') String? receiverUsername,
    @JsonKey(name: 'other_user_image_url') String? otherUserImageUrl,
    @JsonKey(name: 'other_user_first_name') String? otherUserFirstName,
    @JsonKey(name: 'other_user_last_name') String? otherUserLastName,
  });
}

/// @nodoc
class _$InboxItemCopyWithImpl<$Res, $Val extends InboxItem>
    implements $InboxItemCopyWith<$Res> {
  _$InboxItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InboxItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otherUsername = null,
    Object? lastMessage = freezed,
    Object? timestamp = null,
    Object? isEncrypted = null,
    Object? senderUsername = freezed,
    Object? receiverUsername = freezed,
    Object? otherUserImageUrl = freezed,
    Object? otherUserFirstName = freezed,
    Object? otherUserLastName = freezed,
  }) {
    return _then(
      _value.copyWith(
            otherUsername: null == otherUsername
                ? _value.otherUsername
                : otherUsername // ignore: cast_nullable_to_non_nullable
                      as String,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isEncrypted: null == isEncrypted
                ? _value.isEncrypted
                : isEncrypted // ignore: cast_nullable_to_non_nullable
                      as bool,
            senderUsername: freezed == senderUsername
                ? _value.senderUsername
                : senderUsername // ignore: cast_nullable_to_non_nullable
                      as String?,
            receiverUsername: freezed == receiverUsername
                ? _value.receiverUsername
                : receiverUsername // ignore: cast_nullable_to_non_nullable
                      as String?,
            otherUserImageUrl: freezed == otherUserImageUrl
                ? _value.otherUserImageUrl
                : otherUserImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            otherUserFirstName: freezed == otherUserFirstName
                ? _value.otherUserFirstName
                : otherUserFirstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            otherUserLastName: freezed == otherUserLastName
                ? _value.otherUserLastName
                : otherUserLastName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InboxItemImplCopyWith<$Res>
    implements $InboxItemCopyWith<$Res> {
  factory _$$InboxItemImplCopyWith(
    _$InboxItemImpl value,
    $Res Function(_$InboxItemImpl) then,
  ) = __$$InboxItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'other_username') String otherUsername,
    @JsonKey(name: 'last_message') String? lastMessage,
    DateTime timestamp,
    @JsonKey(name: 'is_encrypted') bool isEncrypted,
    @JsonKey(name: 'sender_username') String? senderUsername,
    @JsonKey(name: 'receiver_username') String? receiverUsername,
    @JsonKey(name: 'other_user_image_url') String? otherUserImageUrl,
    @JsonKey(name: 'other_user_first_name') String? otherUserFirstName,
    @JsonKey(name: 'other_user_last_name') String? otherUserLastName,
  });
}

/// @nodoc
class __$$InboxItemImplCopyWithImpl<$Res>
    extends _$InboxItemCopyWithImpl<$Res, _$InboxItemImpl>
    implements _$$InboxItemImplCopyWith<$Res> {
  __$$InboxItemImplCopyWithImpl(
    _$InboxItemImpl _value,
    $Res Function(_$InboxItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InboxItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otherUsername = null,
    Object? lastMessage = freezed,
    Object? timestamp = null,
    Object? isEncrypted = null,
    Object? senderUsername = freezed,
    Object? receiverUsername = freezed,
    Object? otherUserImageUrl = freezed,
    Object? otherUserFirstName = freezed,
    Object? otherUserLastName = freezed,
  }) {
    return _then(
      _$InboxItemImpl(
        otherUsername: null == otherUsername
            ? _value.otherUsername
            : otherUsername // ignore: cast_nullable_to_non_nullable
                  as String,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isEncrypted: null == isEncrypted
            ? _value.isEncrypted
            : isEncrypted // ignore: cast_nullable_to_non_nullable
                  as bool,
        senderUsername: freezed == senderUsername
            ? _value.senderUsername
            : senderUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        receiverUsername: freezed == receiverUsername
            ? _value.receiverUsername
            : receiverUsername // ignore: cast_nullable_to_non_nullable
                  as String?,
        otherUserImageUrl: freezed == otherUserImageUrl
            ? _value.otherUserImageUrl
            : otherUserImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        otherUserFirstName: freezed == otherUserFirstName
            ? _value.otherUserFirstName
            : otherUserFirstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        otherUserLastName: freezed == otherUserLastName
            ? _value.otherUserLastName
            : otherUserLastName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InboxItemImpl implements _InboxItem {
  const _$InboxItemImpl({
    @JsonKey(name: 'other_username') required this.otherUsername,
    @JsonKey(name: 'last_message') this.lastMessage,
    required this.timestamp,
    @JsonKey(name: 'is_encrypted') this.isEncrypted = false,
    @JsonKey(name: 'sender_username') this.senderUsername,
    @JsonKey(name: 'receiver_username') this.receiverUsername,
    @JsonKey(name: 'other_user_image_url') this.otherUserImageUrl,
    @JsonKey(name: 'other_user_first_name') this.otherUserFirstName,
    @JsonKey(name: 'other_user_last_name') this.otherUserLastName,
  });

  factory _$InboxItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InboxItemImplFromJson(json);

  @override
  @JsonKey(name: 'other_username')
  final String otherUsername;
  @override
  @JsonKey(name: 'last_message')
  final String? lastMessage;
  @override
  final DateTime timestamp;
  @override
  @JsonKey(name: 'is_encrypted')
  final bool isEncrypted;
  @override
  @JsonKey(name: 'sender_username')
  final String? senderUsername;
  @override
  @JsonKey(name: 'receiver_username')
  final String? receiverUsername;
  @override
  @JsonKey(name: 'other_user_image_url')
  final String? otherUserImageUrl;
  @override
  @JsonKey(name: 'other_user_first_name')
  final String? otherUserFirstName;
  @override
  @JsonKey(name: 'other_user_last_name')
  final String? otherUserLastName;

  @override
  String toString() {
    return 'InboxItem(otherUsername: $otherUsername, lastMessage: $lastMessage, timestamp: $timestamp, isEncrypted: $isEncrypted, senderUsername: $senderUsername, receiverUsername: $receiverUsername, otherUserImageUrl: $otherUserImageUrl, otherUserFirstName: $otherUserFirstName, otherUserLastName: $otherUserLastName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InboxItemImpl &&
            (identical(other.otherUsername, otherUsername) ||
                other.otherUsername == otherUsername) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isEncrypted, isEncrypted) ||
                other.isEncrypted == isEncrypted) &&
            (identical(other.senderUsername, senderUsername) ||
                other.senderUsername == senderUsername) &&
            (identical(other.receiverUsername, receiverUsername) ||
                other.receiverUsername == receiverUsername) &&
            (identical(other.otherUserImageUrl, otherUserImageUrl) ||
                other.otherUserImageUrl == otherUserImageUrl) &&
            (identical(other.otherUserFirstName, otherUserFirstName) ||
                other.otherUserFirstName == otherUserFirstName) &&
            (identical(other.otherUserLastName, otherUserLastName) ||
                other.otherUserLastName == otherUserLastName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    otherUsername,
    lastMessage,
    timestamp,
    isEncrypted,
    senderUsername,
    receiverUsername,
    otherUserImageUrl,
    otherUserFirstName,
    otherUserLastName,
  );

  /// Create a copy of InboxItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InboxItemImplCopyWith<_$InboxItemImpl> get copyWith =>
      __$$InboxItemImplCopyWithImpl<_$InboxItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InboxItemImplToJson(this);
  }
}

abstract class _InboxItem implements InboxItem {
  const factory _InboxItem({
    @JsonKey(name: 'other_username') required final String otherUsername,
    @JsonKey(name: 'last_message') final String? lastMessage,
    required final DateTime timestamp,
    @JsonKey(name: 'is_encrypted') final bool isEncrypted,
    @JsonKey(name: 'sender_username') final String? senderUsername,
    @JsonKey(name: 'receiver_username') final String? receiverUsername,
    @JsonKey(name: 'other_user_image_url') final String? otherUserImageUrl,
    @JsonKey(name: 'other_user_first_name') final String? otherUserFirstName,
    @JsonKey(name: 'other_user_last_name') final String? otherUserLastName,
  }) = _$InboxItemImpl;

  factory _InboxItem.fromJson(Map<String, dynamic> json) =
      _$InboxItemImpl.fromJson;

  @override
  @JsonKey(name: 'other_username')
  String get otherUsername;
  @override
  @JsonKey(name: 'last_message')
  String? get lastMessage;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(name: 'is_encrypted')
  bool get isEncrypted;
  @override
  @JsonKey(name: 'sender_username')
  String? get senderUsername;
  @override
  @JsonKey(name: 'receiver_username')
  String? get receiverUsername;
  @override
  @JsonKey(name: 'other_user_image_url')
  String? get otherUserImageUrl;
  @override
  @JsonKey(name: 'other_user_first_name')
  String? get otherUserFirstName;
  @override
  @JsonKey(name: 'other_user_last_name')
  String? get otherUserLastName;

  /// Create a copy of InboxItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InboxItemImplCopyWith<_$InboxItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
