import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isNotificationsEnabled = true.obs;
  
  final _box = Get.find<GetStorage>();
  final _key = 'isNotificationsEnabled';
  final _fcmTokenKey = 'last_registered_fcm_token';
  final _deviceIdKey = 'persistent_device_id';
  Timer? _pollingTimer;
  StreamSubscription<String>? _tokenRefreshSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    if (isNotificationsEnabled.value) {
      fetchNotifications();
      startPolling();
      _setupTokenRefreshListener();
    }
  }

  void _setupTokenRefreshListener() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      updateDeviceToken(newToken: newToken);
    });
  }

  void _loadSettings() {
    isNotificationsEnabled.value = _box.read(_key) ?? true;
  }

  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
    _box.write(_key, value);
    if (value) {
      fetchNotifications();
      startPolling();
    } else {
      _pollingTimer?.cancel();
      unreadCount.value = 0;
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    _tokenRefreshSubscription?.cancel();
    super.onClose();
  }

  Future<void> updateDeviceToken({String? newToken}) async {
    try {
      final fcmToken = newToken ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      final lastToken = _box.read(_fcmTokenKey);
      if (lastToken == fcmToken && newToken == null) {
        print('FCM Token already registered and unchanged.');
        return;
      }

      String deviceId = _box.read(_deviceIdKey) ?? '';
      if (deviceId.isEmpty) {
        deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}-${_box.hashCode}';
        await _box.write(_deviceIdKey, deviceId);
      }

      final success = await _service.registerDeviceToken(
        fcmToken: fcmToken,
        deviceId: deviceId,
      );

      if (success) {
        await _box.write(_fcmTokenKey, fcmToken);
        print('Successfully registered device token with backend.');
      }
    } catch (e) {
      print('Error in updateDeviceToken: $e');
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    if (!isNotificationsEnabled.value) return;
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => fetchNotifications(silent: true));
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (!isNotificationsEnabled.value) return;
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

  void clearData() {
    notifications.clear();
    unreadCount.value = 0;
    _pollingTimer?.cancel();
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
