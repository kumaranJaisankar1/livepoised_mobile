import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required dynamic id,
    required String text,
    @JsonKey(name: 'author_name') required String authorName,
    @JsonKey(name: 'author_user_id') String? authorUserId,
    @JsonKey(name: 'author_id') String? authorId,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
    @JsonKey(name: 'author_role') String? authorRole,
    @JsonKey(name: 'parent_id') dynamic parentId,
    @JsonKey(name: 'root_id') dynamic rootId,
    @JsonKey(name: 'post_id') dynamic postId,
    @Default(0) int likes,
    @JsonKey(name: 'liked_by') @Default([]) List<String> likedBy,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'children_count') @Default(0) int childrenCount,
    @Default([]) List<Comment> children,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default(0) int depth,
    String? path,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}
