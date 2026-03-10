// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  dynamic get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_name')
  String get authorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_user_id')
  String? get authorUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_id')
  String? get authorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_image_url')
  String? get authorImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_role')
  String? get authorRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'parent_id')
  dynamic get parentId => throw _privateConstructorUsedError;
  @JsonKey(name: 'root_id')
  dynamic get rootId => throw _privateConstructorUsedError;
  @JsonKey(name: 'post_id')
  dynamic get postId => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  @JsonKey(name: 'liked_by')
  List<String> get likedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_liked')
  bool get isLiked => throw _privateConstructorUsedError;
  @JsonKey(name: 'children_count')
  int get childrenCount => throw _privateConstructorUsedError;
  List<Comment> get children => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  int get depth => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call({
    dynamic id,
    String text,
    @JsonKey(name: 'author_name') String authorName,
    @JsonKey(name: 'author_user_id') String? authorUserId,
    @JsonKey(name: 'author_id') String? authorId,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
    @JsonKey(name: 'author_role') String? authorRole,
    @JsonKey(name: 'parent_id') dynamic parentId,
    @JsonKey(name: 'root_id') dynamic rootId,
    @JsonKey(name: 'post_id') dynamic postId,
    int likes,
    @JsonKey(name: 'liked_by') List<String> likedBy,
    @JsonKey(name: 'is_liked') bool isLiked,
    @JsonKey(name: 'children_count') int childrenCount,
    List<Comment> children,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    int depth,
    String? path,
  });
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? text = null,
    Object? authorName = null,
    Object? authorUserId = freezed,
    Object? authorId = freezed,
    Object? authorImageUrl = freezed,
    Object? authorRole = freezed,
    Object? parentId = freezed,
    Object? rootId = freezed,
    Object? postId = freezed,
    Object? likes = null,
    Object? likedBy = null,
    Object? isLiked = null,
    Object? childrenCount = null,
    Object? children = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? depth = null,
    Object? path = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
            authorUserId: freezed == authorUserId
                ? _value.authorUserId
                : authorUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorId: freezed == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorImageUrl: freezed == authorImageUrl
                ? _value.authorImageUrl
                : authorImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorRole: freezed == authorRole
                ? _value.authorRole
                : authorRole // ignore: cast_nullable_to_non_nullable
                      as String?,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            rootId: freezed == rootId
                ? _value.rootId
                : rootId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            postId: freezed == postId
                ? _value.postId
                : postId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            likes: null == likes
                ? _value.likes
                : likes // ignore: cast_nullable_to_non_nullable
                      as int,
            likedBy: null == likedBy
                ? _value.likedBy
                : likedBy // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isLiked: null == isLiked
                ? _value.isLiked
                : isLiked // ignore: cast_nullable_to_non_nullable
                      as bool,
            childrenCount: null == childrenCount
                ? _value.childrenCount
                : childrenCount // ignore: cast_nullable_to_non_nullable
                      as int,
            children: null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<Comment>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            depth: null == depth
                ? _value.depth
                : depth // ignore: cast_nullable_to_non_nullable
                      as int,
            path: freezed == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
    _$CommentImpl value,
    $Res Function(_$CommentImpl) then,
  ) = __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    String text,
    @JsonKey(name: 'author_name') String authorName,
    @JsonKey(name: 'author_user_id') String? authorUserId,
    @JsonKey(name: 'author_id') String? authorId,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
    @JsonKey(name: 'author_role') String? authorRole,
    @JsonKey(name: 'parent_id') dynamic parentId,
    @JsonKey(name: 'root_id') dynamic rootId,
    @JsonKey(name: 'post_id') dynamic postId,
    int likes,
    @JsonKey(name: 'liked_by') List<String> likedBy,
    @JsonKey(name: 'is_liked') bool isLiked,
    @JsonKey(name: 'children_count') int childrenCount,
    List<Comment> children,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    int depth,
    String? path,
  });
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
    _$CommentImpl _value,
    $Res Function(_$CommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? text = null,
    Object? authorName = null,
    Object? authorUserId = freezed,
    Object? authorId = freezed,
    Object? authorImageUrl = freezed,
    Object? authorRole = freezed,
    Object? parentId = freezed,
    Object? rootId = freezed,
    Object? postId = freezed,
    Object? likes = null,
    Object? likedBy = null,
    Object? isLiked = null,
    Object? childrenCount = null,
    Object? children = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? depth = null,
    Object? path = freezed,
  }) {
    return _then(
      _$CommentImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
        authorUserId: freezed == authorUserId
            ? _value.authorUserId
            : authorUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorId: freezed == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorImageUrl: freezed == authorImageUrl
            ? _value.authorImageUrl
            : authorImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorRole: freezed == authorRole
            ? _value.authorRole
            : authorRole // ignore: cast_nullable_to_non_nullable
                  as String?,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        rootId: freezed == rootId
            ? _value.rootId
            : rootId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        postId: freezed == postId
            ? _value.postId
            : postId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        likes: null == likes
            ? _value.likes
            : likes // ignore: cast_nullable_to_non_nullable
                  as int,
        likedBy: null == likedBy
            ? _value._likedBy
            : likedBy // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isLiked: null == isLiked
            ? _value.isLiked
            : isLiked // ignore: cast_nullable_to_non_nullable
                  as bool,
        childrenCount: null == childrenCount
            ? _value.childrenCount
            : childrenCount // ignore: cast_nullable_to_non_nullable
                  as int,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<Comment>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        depth: null == depth
            ? _value.depth
            : depth // ignore: cast_nullable_to_non_nullable
                  as int,
        path: freezed == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentImpl implements _Comment {
  const _$CommentImpl({
    required this.id,
    required this.text,
    @JsonKey(name: 'author_name') required this.authorName,
    @JsonKey(name: 'author_user_id') this.authorUserId,
    @JsonKey(name: 'author_id') this.authorId,
    @JsonKey(name: 'author_image_url') this.authorImageUrl,
    @JsonKey(name: 'author_role') this.authorRole,
    @JsonKey(name: 'parent_id') this.parentId,
    @JsonKey(name: 'root_id') this.rootId,
    @JsonKey(name: 'post_id') this.postId,
    this.likes = 0,
    @JsonKey(name: 'liked_by') final List<String> likedBy = const [],
    @JsonKey(name: 'is_liked') this.isLiked = false,
    @JsonKey(name: 'children_count') this.childrenCount = 0,
    final List<Comment> children = const [],
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.depth = 0,
    this.path,
  }) : _likedBy = likedBy,
       _children = children;

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final dynamic id;
  @override
  final String text;
  @override
  @JsonKey(name: 'author_name')
  final String authorName;
  @override
  @JsonKey(name: 'author_user_id')
  final String? authorUserId;
  @override
  @JsonKey(name: 'author_id')
  final String? authorId;
  @override
  @JsonKey(name: 'author_image_url')
  final String? authorImageUrl;
  @override
  @JsonKey(name: 'author_role')
  final String? authorRole;
  @override
  @JsonKey(name: 'parent_id')
  final dynamic parentId;
  @override
  @JsonKey(name: 'root_id')
  final dynamic rootId;
  @override
  @JsonKey(name: 'post_id')
  final dynamic postId;
  @override
  @JsonKey()
  final int likes;
  final List<String> _likedBy;
  @override
  @JsonKey(name: 'liked_by')
  List<String> get likedBy {
    if (_likedBy is EqualUnmodifiableListView) return _likedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedBy);
  }

  @override
  @JsonKey(name: 'is_liked')
  final bool isLiked;
  @override
  @JsonKey(name: 'children_count')
  final int childrenCount;
  final List<Comment> _children;
  @override
  @JsonKey()
  List<Comment> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final int depth;
  @override
  final String? path;

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, authorName: $authorName, authorUserId: $authorUserId, authorId: $authorId, authorImageUrl: $authorImageUrl, authorRole: $authorRole, parentId: $parentId, rootId: $rootId, postId: $postId, likes: $likes, likedBy: $likedBy, isLiked: $isLiked, childrenCount: $childrenCount, children: $children, createdAt: $createdAt, updatedAt: $updatedAt, depth: $depth, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorUserId, authorUserId) ||
                other.authorUserId == authorUserId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorImageUrl, authorImageUrl) ||
                other.authorImageUrl == authorImageUrl) &&
            (identical(other.authorRole, authorRole) ||
                other.authorRole == authorRole) &&
            const DeepCollectionEquality().equals(other.parentId, parentId) &&
            const DeepCollectionEquality().equals(other.rootId, rootId) &&
            const DeepCollectionEquality().equals(other.postId, postId) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            const DeepCollectionEquality().equals(other._likedBy, _likedBy) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.childrenCount, childrenCount) ||
                other.childrenCount == childrenCount) &&
            const DeepCollectionEquality().equals(other._children, _children) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.depth, depth) || other.depth == depth) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    const DeepCollectionEquality().hash(id),
    text,
    authorName,
    authorUserId,
    authorId,
    authorImageUrl,
    authorRole,
    const DeepCollectionEquality().hash(parentId),
    const DeepCollectionEquality().hash(rootId),
    const DeepCollectionEquality().hash(postId),
    likes,
    const DeepCollectionEquality().hash(_likedBy),
    isLiked,
    childrenCount,
    const DeepCollectionEquality().hash(_children),
    createdAt,
    updatedAt,
    depth,
    path,
  ]);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(this);
  }
}

abstract class _Comment implements Comment {
  const factory _Comment({
    required final dynamic id,
    required final String text,
    @JsonKey(name: 'author_name') required final String authorName,
    @JsonKey(name: 'author_user_id') final String? authorUserId,
    @JsonKey(name: 'author_id') final String? authorId,
    @JsonKey(name: 'author_image_url') final String? authorImageUrl,
    @JsonKey(name: 'author_role') final String? authorRole,
    @JsonKey(name: 'parent_id') final dynamic parentId,
    @JsonKey(name: 'root_id') final dynamic rootId,
    @JsonKey(name: 'post_id') final dynamic postId,
    final int likes,
    @JsonKey(name: 'liked_by') final List<String> likedBy,
    @JsonKey(name: 'is_liked') final bool isLiked,
    @JsonKey(name: 'children_count') final int childrenCount,
    final List<Comment> children,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
    final int depth,
    final String? path,
  }) = _$CommentImpl;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  dynamic get id;
  @override
  String get text;
  @override
  @JsonKey(name: 'author_name')
  String get authorName;
  @override
  @JsonKey(name: 'author_user_id')
  String? get authorUserId;
  @override
  @JsonKey(name: 'author_id')
  String? get authorId;
  @override
  @JsonKey(name: 'author_image_url')
  String? get authorImageUrl;
  @override
  @JsonKey(name: 'author_role')
  String? get authorRole;
  @override
  @JsonKey(name: 'parent_id')
  dynamic get parentId;
  @override
  @JsonKey(name: 'root_id')
  dynamic get rootId;
  @override
  @JsonKey(name: 'post_id')
  dynamic get postId;
  @override
  int get likes;
  @override
  @JsonKey(name: 'liked_by')
  List<String> get likedBy;
  @override
  @JsonKey(name: 'is_liked')
  bool get isLiked;
  @override
  @JsonKey(name: 'children_count')
  int get childrenCount;
  @override
  List<Comment> get children;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  int get depth;
  @override
  String? get path;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
