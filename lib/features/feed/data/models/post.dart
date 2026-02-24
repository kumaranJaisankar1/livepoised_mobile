import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
    required DateTime createdAt,
    @Default(0) int likesCount,
    @Default(0) int repliesCount,
    @Default([]) List<String> hashtags,
    String? medicalCategory,
    @Default(false) bool isLiked,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
