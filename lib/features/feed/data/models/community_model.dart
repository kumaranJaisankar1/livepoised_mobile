import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_model.freezed.dart';
part 'community_model.g.dart';

@freezed
class CommunityModel with _$CommunityModel {
  const factory CommunityModel({
    required dynamic id,
    required String name,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _CommunityModel;

  factory CommunityModel.fromJson(Map<String, dynamic> json) => _$CommunityModelFromJson(json);
}
