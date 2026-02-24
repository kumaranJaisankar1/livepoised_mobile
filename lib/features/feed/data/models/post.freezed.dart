// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Post _$PostFromJson(Map<String, dynamic> json) {
  return _Post.fromJson(json);
}

/// @nodoc
mixin _$Post {
  String get id => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  String? get authorAvatar => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get likesCount => throw _privateConstructorUsedError;
  int get repliesCount => throw _privateConstructorUsedError;
  List<String> get hashtags => throw _privateConstructorUsedError;
  String? get medicalCategory => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCopyWith<Post> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCopyWith<$Res> {
  factory $PostCopyWith(Post value, $Res Function(Post) then) =
      _$PostCopyWithImpl<$Res, Post>;
  @useResult
  $Res call({
    String id,
    String authorId,
    String authorName,
    String? authorAvatar,
    String content,
    DateTime createdAt,
    int likesCount,
    int repliesCount,
    List<String> hashtags,
    String? medicalCategory,
    bool isLiked,
  });
}

/// @nodoc
class _$PostCopyWithImpl<$Res, $Val extends Post>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? authorAvatar = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? likesCount = null,
    Object? repliesCount = null,
    Object? hashtags = null,
    Object? medicalCategory = freezed,
    Object? isLiked = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            authorAvatar: freezed == authorAvatar
                ? _value.authorAvatar
                : authorAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            likesCount: null == likesCount
                ? _value.likesCount
                : likesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            repliesCount: null == repliesCount
                ? _value.repliesCount
                : repliesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            hashtags: null == hashtags
                ? _value.hashtags
                : hashtags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            medicalCategory: freezed == medicalCategory
                ? _value.medicalCategory
                : medicalCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLiked: null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PostImplCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$$PostImplCopyWith(
    _$PostImpl value,
    $Res Function(_$PostImpl) then,
  ) = __$$PostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String authorId,
    String authorName,
    String? authorAvatar,
    String content,
    DateTime createdAt,
    int likesCount,
    int repliesCount,
    List<String> hashtags,
    String? medicalCategory,
    bool isLiked,
  });
}

/// @nodoc
class __$$PostImplCopyWithImpl<$Res>
    extends _$PostCopyWithImpl<$Res, _$PostImpl>
    implements _$$PostImplCopyWith<$Res> {
  __$$PostImplCopyWithImpl(_$PostImpl _value, $Res Function(_$PostImpl) _then)
    : super(_value, _then);

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = null,
    Object? authorAvatar = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? likesCount = null,
    Object? repliesCount = null,
    Object? hashtags = null,
    Object? medicalCategory = freezed,
    Object? isLiked = null,
  }) {
    return _then(
      _$PostImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        authorAvatar: freezed == authorAvatar
            ? _value.authorAvatar
            : authorAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        likesCount: null == likesCount
            ? _value.likesCount
            : likesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        repliesCount: null == repliesCount
            ? _value.repliesCount
            : repliesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        hashtags: null == hashtags
            ? _value._hashtags
            : hashtags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        medicalCategory: freezed == medicalCategory
            ? _value.medicalCategory
            : medicalCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLiked: null == isLiked
            ? _value.isLiked
            : isLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.repliesCount = 0,
    final List<String> hashtags = const [],
    this.medicalCategory,
    this.isLiked = false,
  }) : _hashtags = hashtags;

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final String id;
  @override
  final String authorId;
  @override
  final String authorName;
  @override
  final String? authorAvatar;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int likesCount;
  @override
  @JsonKey()
  final int repliesCount;
  final List<String> _hashtags;
  @override
  @JsonKey()
  List<String> get hashtags {
    if (_hashtags is EqualUnmodifiableListView) return _hashtags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hashtags);
  }

  @override
  final String? medicalCategory;
  @override
  @JsonKey()
  final bool isLiked;

  @override
  String toString() {
    return 'Post(id: $id, authorId: $authorId, authorName: $authorName, authorAvatar: $authorAvatar, content: $content, createdAt: $createdAt, likesCount: $likesCount, repliesCount: $repliesCount, hashtags: $hashtags, medicalCategory: $medicalCategory, isLiked: $isLiked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorAvatar, authorAvatar) ||
                other.authorAvatar == authorAvatar) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.likesCount, likesCount) ||
                other.likesCount == likesCount) &&
            (identical(other.repliesCount, repliesCount) ||
                other.repliesCount == repliesCount) &&
            const DeepCollectionEquality().equals(other._hashtags, _hashtags) &&
            (identical(other.medicalCategory, medicalCategory) ||
                other.medicalCategory == medicalCategory) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    authorId,
    authorName,
    authorAvatar,
    content,
    createdAt,
    likesCount,
    repliesCount,
    const DeepCollectionEquality().hash(_hashtags),
    medicalCategory,
    isLiked,
  );

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      __$$PostImplCopyWithImpl<_$PostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostImplToJson(this);
  }
}

abstract class _Post implements Post {
  const factory _Post({
    required final String id,
    required final String authorId,
    required final String authorName,
    final String? authorAvatar,
    required final String content,
    required final DateTime createdAt,
    final int likesCount,
    final int repliesCount,
    final List<String> hashtags,
    final String? medicalCategory,
    final bool isLiked,
  }) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  String get id;
  @override
  String get authorId;
  @override
  String get authorName;
  @override
  String? get authorAvatar;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  int get likesCount;
  @override
  int get repliesCount;
  @override
  List<String> get hashtags;
  @override
  String? get medicalCategory;
  @override
  bool get isLiked;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
