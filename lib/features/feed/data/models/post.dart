import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required dynamic id, // API says id can be any (UUID or number)
    required String title,
    required String content,
    @Default([]) List<String> tags,
    @JsonKey(name: 'author_name') required String authorName,
    @JsonKey(name: 'author_role') required String authorRole,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
    @Default(0) int likes,
    @JsonKey(name: 'comments_count') @Default(0) int commentsCount,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // Additional fields from sample JSON
    String? visibility,
    @JsonKey(name: 'community_id') dynamic communityId,
    @JsonKey(name: 'author_user_id') String? authorUserId,
    @JsonKey(name: 'liked_by') @Default([]) List<String> likedBy,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

