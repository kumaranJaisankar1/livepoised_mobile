// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_post_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreatePostRequest _$CreatePostRequestFromJson(Map<String, dynamic> json) {
  return _CreatePostRequest.fromJson(json);
}

/// @nodoc
mixin _$CreatePostRequest {
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_image_url')
  String? get authorImageUrl => throw _privateConstructorUsedError;

  /// Serializes this CreatePostRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreatePostRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatePostRequestCopyWith<CreatePostRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePostRequestCopyWith<$Res> {
  factory $CreatePostRequestCopyWith(
    CreatePostRequest value,
    $Res Function(CreatePostRequest) then,
  ) = _$CreatePostRequestCopyWithImpl<$Res, CreatePostRequest>;
  @useResult
  $Res call({
    String title,
    String content,
    List<String> tags,
    String visibility,
    String username,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
  });
}

/// @nodoc
class _$CreatePostRequestCopyWithImpl<$Res, $Val extends CreatePostRequest>
    implements $CreatePostRequestCopyWith<$Res> {
  _$CreatePostRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatePostRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? visibility = null,
    Object? username = null,
    Object? authorImageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            visibility: null == visibility
                ? _value.visibility
                : visibility // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            authorImageUrl: freezed == authorImageUrl
                ? _value.authorImageUrl
                : authorImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreatePostRequestImplCopyWith<$Res>
    implements $CreatePostRequestCopyWith<$Res> {
  factory _$$CreatePostRequestImplCopyWith(
    _$CreatePostRequestImpl value,
    $Res Function(_$CreatePostRequestImpl) then,
  ) = __$$CreatePostRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String content,
    List<String> tags,
    String visibility,
    String username,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
  });
}

/// @nodoc
class __$$CreatePostRequestImplCopyWithImpl<$Res>
    extends _$CreatePostRequestCopyWithImpl<$Res, _$CreatePostRequestImpl>
    implements _$$CreatePostRequestImplCopyWith<$Res> {
  __$$CreatePostRequestImplCopyWithImpl(
    _$CreatePostRequestImpl _value,
    $Res Function(_$CreatePostRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreatePostRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? visibility = null,
    Object? username = null,
    Object? authorImageUrl = freezed,
  }) {
    return _then(
      _$CreatePostRequestImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        visibility: null == visibility
            ? _value.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        authorImageUrl: freezed == authorImageUrl
            ? _value.authorImageUrl
            : authorImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatePostRequestImpl implements _CreatePostRequest {
  const _$CreatePostRequestImpl({
    required this.title,
    required this.content,
    required final List<String> tags,
    this.visibility = "public",
    required this.username,
    @JsonKey(name: 'author_image_url') this.authorImageUrl,
  }) : _tags = tags;

  factory _$CreatePostRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatePostRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String content;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String visibility;
  @override
  final String username;
  @override
  @JsonKey(name: 'author_image_url')
  final String? authorImageUrl;

  @override
  String toString() {
    return 'CreatePostRequest(title: $title, content: $content, tags: $tags, visibility: $visibility, username: $username, authorImageUrl: $authorImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePostRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.authorImageUrl, authorImageUrl) ||
                other.authorImageUrl == authorImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    content,
    const DeepCollectionEquality().hash(_tags),
    visibility,
    username,
    authorImageUrl,
  );

  /// Create a copy of CreatePostRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePostRequestImplCopyWith<_$CreatePostRequestImpl> get copyWith =>
      __$$CreatePostRequestImplCopyWithImpl<_$CreatePostRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatePostRequestImplToJson(this);
  }
}

abstract class _CreatePostRequest implements CreatePostRequest {
  const factory _CreatePostRequest({
    required final String title,
    required final String content,
    required final List<String> tags,
    final String visibility,
    required final String username,
    @JsonKey(name: 'author_image_url') final String? authorImageUrl,
  }) = _$CreatePostRequestImpl;

  factory _CreatePostRequest.fromJson(Map<String, dynamic> json) =
      _$CreatePostRequestImpl.fromJson;

  @override
  String get title;
  @override
  String get content;
  @override
  List<String> get tags;
  @override
  String get visibility;
  @override
  String get username;
  @override
  @JsonKey(name: 'author_image_url')
  String? get authorImageUrl;

  /// Create a copy of CreatePostRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatePostRequestImplCopyWith<_$CreatePostRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
