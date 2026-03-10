import 'package:freezed_annotation/freezed_annotation.dart';
import 'post.dart';
import 'comment.dart';

part 'post_detail_response.freezed.dart';
part 'post_detail_response.g.dart';

@freezed
class PostDetailResponse with _$PostDetailResponse {
  const factory PostDetailResponse({
    required Post post,
    @JsonKey(name: 'comments_tree') @Default([]) List<Comment> commentsTree,
  }) = _PostDetailResponse;

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) => _$PostDetailResponseFromJson(json);
}
