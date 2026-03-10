import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post_request.freezed.dart';
part 'create_post_request.g.dart';

@freezed
class CreatePostRequest with _$CreatePostRequest {
  const factory CreatePostRequest({
    required String title,
    required String content,
    required List<String> tags,
    @Default("public") String visibility,
    required String username,
    @JsonKey(name: 'author_image_url') String? authorImageUrl,
  }) = _CreatePostRequest;

  factory CreatePostRequest.fromJson(Map<String, dynamic> json) => _$CreatePostRequestFromJson(json);
}
