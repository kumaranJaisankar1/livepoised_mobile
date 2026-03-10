import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required int id,
    @JsonKey(name: 'recipientUsername') required String recipientUsername,
    required String type,
    required String message,
    @JsonKey(name: 'senderUsername') String? senderUsername,
    @JsonKey(name: 'referenceId') dynamic referenceId,
    @Default(false) bool read,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);

  // Helper for deep linking
  NotificationType get notificationType {
    switch (type) {
      case 'ALLY_REQUEST':
        return NotificationType.allyRequest;
      case 'ALLY_REQUEST_ACCEPTED':
        return NotificationType.allyRequestAccepted;
      case 'CHAT_MESSAGE':
        return NotificationType.chatMessage;
      case 'FORUM_POST_REPLY':
        return NotificationType.forumPostReply;
      case 'MENTOR_REQUEST':
        return NotificationType.mentorRequest;
      case 'GOAL_MILESTONE':
        return NotificationType.goalMilestone;
      case 'COMMENT_LIKE':
        return NotificationType.commentLike;
      case 'POST_LIKE':
        return NotificationType.postLike;
      default:
        return NotificationType.unknown;
    }
  }
}

enum NotificationType {
  allyRequest,
  allyRequestAccepted,
  chatMessage,
  forumPostReply,
  mentorRequest,
  goalMilestone,
  commentLike,
  postLike,
  unknown
}
