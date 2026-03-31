import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handling
  print("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    print('PNS: Starting initialization');
    // 1. Request permissions (especially for iOS)
    print('PNS: Requesting FCM permission...');
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // 2. Initialize Local Notifications for Foreground
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    print('PNS: Initializing local notifications...');
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final Map<String, dynamic> data = jsonDecode(response.payload!);
          handleNavigation(data);
        }
      },
    );

    print('PNS: Setting up FCM message listeners...');
    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _showLocalNotification(notification, message.data);
      }
    });

    // 4. Handle Notification Click when App is in Background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked (Background stage)');
      handleNavigation(message.data);
    });

    // 5. Check for Terminated State Launch
    print('PNS: Getting initial FCM message...');
    _fcm.getInitialMessage().then((RemoteMessage? initialMessage) {
      if (initialMessage != null) {
        print('Notification clicked (Terminated stage)');
        handleNavigation(initialMessage.data);
      }
    }).catchError((e) {
      print('PNS Error: Failed to get initial message: $e');
    });
    
    print('PNS: Initialization complete');
  }

  void _showLocalNotification(RemoteNotification notification, Map<String, dynamic> data) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(data),
    );
  }

  void handleNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final dynamic referenceId = data['referenceId'];

    print('Directing navigation for type: $type, referenceId: $referenceId');

    if (type == null) return;

    switch (type) {
      case 'CHAT_MESSAGE':
        // Assuming referenceId is the senderUsername or chatSessionId
        if (referenceId != null) {
          Get.toNamed('/chat', arguments: referenceId.toString());
        }
        break;
      case 'ALLY_REQUEST':
      case 'CAREGIVER_REQUEST':
        Get.toNamed('/network');
        break;
      default:
        print('Unknown notification type or no specific route: $type');
        break;
    }
  }
}
