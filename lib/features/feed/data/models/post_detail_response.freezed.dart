// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PostDetailResponse _$PostDetailResponseFromJson(Map<String, dynamic> json) {
  return _PostDetailResponse.fromJson(json);
}

/// @nodoc
mixin _$PostDetailResponse {
  Post get post => throw _privateConstructorUsedError;
  @JsonKey(name: 'comments_tree')
  List<Comment> get commentsTree => throw _privateConstructorUsedError;

  /// Serializes this PostDetailResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PostDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostDetailResponseCopyWith<PostDetailResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostDetailResponseCopyWith<$Res> {
  factory $PostDetailResponseCopyWith(
    PostDetailResponse value,
    $Res Function(PostDetailResponse) then,
  ) = _$PostDetailResponseCopyWithImpl<$Res, PostDetailResponse>;
  @useResult
  $Res call({
    Post post,
    @JsonKey(name: 'comments_tree') List<Comment> commentsTree,
  });

  $PostCopyWith<$Res> get post;
}

/// @nodoc
class _$PostDetailResponseCopyWithImpl<$Res, $Val extends PostDetailResponse>
    implements $PostDetailResponseCopyWith<$Res> {
  _$PostDetailResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? post = null, Object? commentsTree = null}) {
    return _then(
      _value.copyWith(
            post: null == post
                ? _value.post
                : post // ignore: cast_nullable_to_non_nullable
                      as Post,
            commentsTree: null == commentsTree
                ? _value.commentsTree
                : commentsTree // ignore: cast_nullable_to_non_nullable
                      as List<Comment>,
          )
          as $Val,
    );
  }

  /// Create a copy of PostDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostCopyWith<$Res> get post {
    return $PostCopyWith<$Res>(_value.post, (value) {
      return _then(_value.copyWith(post: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PostDetailResponseImplCopyWith<$Res>
    implements $PostDetailResponseCopyWith<$Res> {
  factory _$$PostDetailResponseImplCopyWith(
    _$PostDetailResponseImpl value,
    $Res Function(_$PostDetailResponseImpl) then,
  ) = __$$PostDetailResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Post post,
    @JsonKey(name: 'comments_tree') List<Comment> commentsTree,
  });

  @override
  $PostCopyWith<$Res> get post;
}

/// @nodoc
class __$$PostDetailResponseImplCopyWithImpl<$Res>
    extends _$PostDetailResponseCopyWithImpl<$Res, _$PostDetailResponseImpl>
    implements _$$PostDetailResponseImplCopyWith<$Res> {
  __$$PostDetailResponseImplCopyWithImpl(
    _$PostDetailResponseImpl _value,
    $Res Function(_$PostDetailResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PostDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? post = null, Object? commentsTree = null}) {
    return _then(
      _$PostDetailResponseImpl(
        post: null == post
            ? _value.post
            : post // ignore: cast_nullable_to_non_nullable
                  as Post,
        commentsTree: null == commentsTree
            ? _value._commentsTree
            : commentsTree // ignore: cast_nullable_to_non_nullable
                  as List<Comment>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PostDetailResponseImpl implements _PostDetailResponse {
  const _$PostDetailResponseImpl({
    required this.post,
    @JsonKey(name: 'comments_tree') final List<Comment> commentsTree = const [],
  }) : _commentsTree = commentsTree;

  factory _$PostDetailResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostDetailResponseImplFromJson(json);

  @override
  final Post post;
  final List<Comment> _commentsTree;
  @override
  @JsonKey(name: 'comments_tree')
  List<Comment> get commentsTree {
    if (_commentsTree is EqualUnmodifiableListView) return _commentsTree;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commentsTree);
  }

  @override
  String toString() {
    return 'PostDetailResponse(post: $post, commentsTree: $commentsTree)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostDetailResponseImpl &&
            (identical(other.post, post) || other.post == post) &&
            const DeepCollectionEquality().equals(
              other._commentsTree,
              _commentsTree,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    post,
    const DeepCollectionEquality().hash(_commentsTree),
  );

  /// Create a copy of PostDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostDetailResponseImplCopyWith<_$PostDetailResponseImpl> get copyWith =>
      __$$PostDetailResponseImplCopyWithImpl<_$PostDetailResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PostDetailResponseImplToJson(this);
  }
}

abstract class _PostDetailResponse implements PostDetailResponse {
  const factory _PostDetailResponse({
    required final Post post,
    @JsonKey(name: 'comments_tree') final List<Comment> commentsTree,
  }) = _$PostDetailResponseImpl;

  factory _PostDetailResponse.fromJson(Map<String, dynamic> json) =
      _$PostDetailResponseImpl.fromJson;

  @override
  Post get post;
  @override
  @JsonKey(name: 'comments_tree')
  List<Comment> get commentsTree;

  /// Create a copy of PostDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostDetailResponseImplCopyWith<_$PostDetailResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
