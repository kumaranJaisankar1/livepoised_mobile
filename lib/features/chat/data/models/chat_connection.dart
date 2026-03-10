import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_connection.freezed.dart';
part 'chat_connection.g.dart';

@freezed
class ChatConnection with _$ChatConnection {
  const factory ChatConnection({
    required String username,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'profileImage') String? profileImage,
    @JsonKey(name: 'connectionType') String? connectionType,
    @JsonKey(name: 'relationship') String? relationship,
  }) = _ChatConnection;

  factory ChatConnection.fromJson(Map<String, dynamic> json) => _$ChatConnectionFromJson(json);
}
