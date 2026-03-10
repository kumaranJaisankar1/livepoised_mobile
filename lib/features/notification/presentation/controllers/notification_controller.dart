import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';


class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => fetchNotifications(silent: true));
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final all = await _service.getAllNotifications();
      notifications.assignAll(all);
      
      final unread = await _service.getUnreadNotifications();
      unreadCount.value = unread.length;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> markAsRead(int id) async {
    final success = await _service.markAsRead(id);
    if (success) {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(read: true);
        if (unreadCount.value > 0) unreadCount.value--;
      }
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = notifications.where((n) => !n.read).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    final success = await _service.markAllAsRead(unreadIds);
    if (success) {
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].read) {
          notifications[i] = notifications[i].copyWith(read: true);
        }
      }
      unreadCount.value = 0;
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    if (!notification.read) {
      markAsRead(notification.id);
    }

    switch (notification.notificationType) {
      case NotificationType.chatMessage:
        Get.toNamed('/chat', arguments: notification.senderUsername);
        break;
      case NotificationType.allyRequest:
        // Assuming there's a network/allies screen
        Get.toNamed('/network'); 
        break;
      case NotificationType.allyRequestAccepted:
        if (notification.senderUsername != null) {
          Get.toNamed('/profile', arguments: notification.senderUsername);
        }
        break;
      case NotificationType.forumPostReply:
      case NotificationType.commentLike:
      case NotificationType.postLike:
        if (notification.referenceId != null) {
          Get.toNamed('/post-details', arguments: notification.referenceId);
        }
        break;
      case NotificationType.mentorRequest:
        Get.toNamed('/mentor-dashboard');
        break;
      case NotificationType.goalMilestone:
        Get.toNamed('/goals');
        break;
      case NotificationType.unknown:
      default:
        print('Unknown notification type: ${notification.type}');
        break;
    }
  }
}
