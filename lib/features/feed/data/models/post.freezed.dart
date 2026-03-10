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
  dynamic get id =>
      throw _privateConstructorUsedError; // API says id can be any (UUID or number)
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_name')
  String get authorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_role')
  String get authorRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_image_url')
  String? get authorImageUrl => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  @JsonKey(name: 'comments_count')
  int get commentsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_liked')
  bool get isLiked => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError; // Additional fields from sample JSON
  String? get visibility => throw _privateConstructorUsedError;
  @JsonKey(name: 'community_id')
  dynamic get communityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_user_id')
  String? get authorUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'liked_by')
  List<String> get likedBy => throw _privateConstructorUsedError;

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
    dynamic id,
    String title,
    String content,
    List<String> tags,
    @JsonKey(name: 'author_name') String authorName,
    @JsonKey(name: 'author_role') String authorRole,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
    int likes,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'is_liked') bool isLiked,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    String? visibility,
    @JsonKey(name: 'community_id') dynamic communityId,
    @JsonKey(name: 'author_user_id') String? authorUserId,
    @JsonKey(name: 'liked_by') List<String> likedBy,
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
    Object? id = freezed,
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? authorName = null,
    Object? authorRole = null,
    Object? authorImageUrl = freezed,
    Object? likes = null,
    Object? commentsCount = null,
    Object? isLiked = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? visibility = freezed,
    Object? communityId = freezed,
    Object? authorUserId = freezed,
    Object? likedBy = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
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
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            authorRole: null == authorRole
                ? _value.authorRole
                : authorRole // ignore: cast_nullable_to_non_nullable
                      as String,
            authorImageUrl: freezed == authorImageUrl
                ? _value.authorImageUrl
                : authorImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            likes: null == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                      as int,
            commentsCount: null == commentsCount
                ? _value.commentsCount
                : commentsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isLiked: null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            visibility: freezed == visibility
                ? _value.visibility
                : visibility // ignore: cast_nullable_to_non_nullable
                      as String?,
            communityId: freezed == communityId
                ? _value.communityId
                : communityId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            authorUserId: freezed == authorUserId
                ? _value.authorUserId
                : authorUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            likedBy: null == likedBy
                ? _value.likedBy
                : likedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
    dynamic id,
    String title,
    String content,
    List<String> tags,
    @JsonKey(name: 'author_name') String authorName,
    @JsonKey(name: 'author_role') String authorRole,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
    int likes,
    @JsonKey(name: 'comments_count') int commentsCount,
    @JsonKey(name: 'is_liked') bool isLiked,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    String? visibility,
    @JsonKey(name: 'community_id') dynamic communityId,
    @JsonKey(name: 'author_user_id') String? authorUserId,
    @JsonKey(name: 'liked_by') List<String> likedBy,
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
    Object? id = freezed,
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? authorName = null,
    Object? authorRole = null,
    Object? authorImageUrl = freezed,
    Object? likes = null,
    Object? commentsCount = null,
    Object? isLiked = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? visibility = freezed,
    Object? communityId = freezed,
    Object? authorUserId = freezed,
    Object? likedBy = null,
  }) {
    return _then(
      _$PostImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
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
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        authorRole: null == authorRole
            ? _value.authorRole
            : authorRole // ignore: cast_nullable_to_non_nullable
                  as String,
        authorImageUrl: freezed == authorImageUrl
            ? _value.authorImageUrl
            : authorImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        likes: null == likes
            ? _value.likes
            : likes // ignore: cast_nullable_to_non_nullable
                  as int,
        commentsCount: null == commentsCount
            ? _value.commentsCount
            : commentsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isLiked: null == isLiked
            ? _value.isLiked
            : isLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        visibility: freezed == visibility
            ? _value.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as String?,
        communityId: freezed == communityId
            ? _value.communityId
            : communityId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        authorUserId: freezed == authorUserId
            ? _value.authorUserId
            : authorUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        likedBy: null == likedBy
            ? _value._likedBy
            : likedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostImpl implements _Post {
  const _$PostImpl({
    required this.id,
    required this.title,
    required this.content,
    final List<String> tags = const [],
    @JsonKey(name: 'author_name') required this.authorName,
    @JsonKey(name: 'author_role') required this.authorRole,
    @JsonKey(name: 'author_image_url') this.authorImageUrl,
    this.likes = 0,
    @JsonKey(name: 'comments_count') this.commentsCount = 0,
    @JsonKey(name: 'is_liked') this.isLiked = false,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.visibility,
    @JsonKey(name: 'community_id') this.communityId,
    @JsonKey(name: 'author_user_id') this.authorUserId,
    @JsonKey(name: 'liked_by') final List<String> likedBy = const [],
  }) : _tags = tags,
       _likedBy = likedBy;

  factory _$PostImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostImplFromJson(json);

  @override
  final dynamic id;
  // API says id can be any (UUID or number)
  @override
  final String title;
  @override
  final String content;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'author_name')
  final String authorName;
  @override
  @JsonKey(name: 'author_role')
  final String authorRole;
  @override
  @JsonKey(name: 'author_image_url')
  final String? authorImageUrl;
  @override
  @JsonKey()
  final int likes;
  @override
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @override
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  // Additional fields from sample JSON
  @override
  final String? visibility;
  @override
  @JsonKey(name: 'community_id')
  final dynamic communityId;
  @override
  @JsonKey(name: 'author_user_id')
  final String? authorUserId;
  final List<String> _likedBy;
  @override
  @JsonKey(name: 'liked_by')
  List<String> get likedBy {
    if (_likedBy is EqualUnmodifiableListView) return _likedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedBy);
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, content: $content, tags: $tags, authorName: $authorName, authorRole: $authorRole, authorImageUrl: $authorImageUrl, likes: $likes, commentsCount: $commentsCount, isLiked: $isLiked, createdAt: $createdAt, updatedAt: $updatedAt, visibility: $visibility, communityId: $communityId, authorUserId: $authorUserId, likedBy: $likedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorRole, authorRole) ||
                other.authorRole == authorRole) &&
            (identical(other.authorImageUrl, authorImageUrl) ||
                other.authorImageUrl == authorImageUrl) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.commentsCount, commentsCount) ||
                other.commentsCount == commentsCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            const DeepCollectionEquality().equals(
              other.communityId,
              communityId,
            ) &&
            (identical(other.authorUserId, authorUserId) ||
                other.authorUserId == authorUserId) &&
            const DeepCollectionEquality().equals(other._likedBy, _likedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(id),
    title,
    content,
    const DeepCollectionEquality().hash(_tags),
    authorName,
    authorRole,
    authorImageUrl,
    likes,
    commentsCount,
    isLiked,
    createdAt,
    updatedAt,
    visibility,
    const DeepCollectionEquality().hash(communityId),
    authorUserId,
    const DeepCollectionEquality().hash(_likedBy),
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
    required final dynamic id,
    required final String title,
    required final String content,
    final List<String> tags,
    @JsonKey(name: 'author_name') required final String authorName,
    @JsonKey(name: 'author_role') required final String authorRole,
    @JsonKey(name: 'author_image_url') final String? authorImageUrl,
    final int likes,
    @JsonKey(name: 'comments_count') final int commentsCount,
    @JsonKey(name: 'is_liked') final bool isLiked,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    final String? visibility,
    @JsonKey(name: 'community_id') final dynamic communityId,
    @JsonKey(name: 'author_user_id') final String? authorUserId,
    @JsonKey(name: 'liked_by') final List<String> likedBy,
  }) = _$PostImpl;

  factory _Post.fromJson(Map<String, dynamic> json) = _$PostImpl.fromJson;

  @override
  dynamic get id; // API says id can be any (UUID or number)
  @override
  String get title;
  @override
  String get content;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'author_name')
  String get authorName;
  @override
  @JsonKey(name: 'author_role')
  String get authorRole;
  @override
  @JsonKey(name: 'author_image_url')
  String? get authorImageUrl;
  @override
  int get likes;
  @override
  @JsonKey(name: 'comments_count')
  int get commentsCount;
  @override
  @JsonKey(name: 'is_liked')
  bool get isLiked;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt; // Additional fields from sample JSON
  @override
  String? get visibility;
  @override
  @JsonKey(name: 'community_id')
  dynamic get communityId;
  @override
  @JsonKey(name: 'author_user_id')
  String? get authorUserId;
  @override
  @JsonKey(name: 'liked_by')
  List<String> get likedBy;

  /// Create a copy of Post
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostImplCopyWith<_$PostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
