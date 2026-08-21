import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../features/call/data/livekit_service.dart';
import '../../features/notification/data/services/notification_service.dart';
import '../constants/api_endpoints.dart';

const String _pendingCallActionKey = 'pending_call_action';

/// Declines an incoming call without any live GetX/app state — safe to call
/// from a background isolate (Android, app fully terminated) or before GetX
/// has finished bootstrapping.
Future<void> _declineCallHeadless(Map<String, dynamic> data) async {
  try {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp();
      } catch (_) {}
    }
    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env.dev');
      } catch (_) {}
    }

    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) return;

    final baseUrl = ApiEndpoints.baseUrlFastAPI;
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ));

    await dio.post('/call/decline', data: {
      'roomId': data['roomId'],
      'receiver': data['sender'],
      'senderFullName': data['senderFullName'],
      'isVideo': data['isVideo'] == 'true' || data['isVideo'] == true,
    });
  } catch (e) {
    print('PNS: Headless decline call failed: $e');
  }
}

/// Persists an "accept this call" marker that survives across isolates/cold
/// starts — works with no GetX/LiveKitService present. `InitialBinding`
/// consumes it once GetX has actually booted, which avoids a race where the
/// notification response arrives before `LiveKitService` is registered.
Future<void> _persistPendingAcceptAction(Map<String, dynamic> data) async {
  try {
    await GetStorage.init();
    final box = GetStorage();
    await box.write(_pendingCallActionKey, {
      'action': 'accept',
      'roomId': data['roomId'],
      'sender': data['sender'],
      'senderFullName': data['senderFullName'],
      'senderImage': data['senderImage'],
      'isVideo': data['isVideo'] == 'true' || data['isVideo'] == true,
    });
  } catch (e) {
    print('PNS: Failed to persist pending accept action: $e');
  }
}

// NOTE: on Android, `showsUserInterface: false` actions (Decline) are always
// routed here via a dedicated headless FlutterEngine, regardless of whether
// the main app process is alive — this is the ONLY code path that ever runs
// for Decline. `showsUserInterface: true` actions (Accept) always launch the
// Activity directly instead and are delivered via the normal main-isolate
// `onDidReceiveNotificationResponse` callback below, never here.
@pragma('vm:entry-point')
Future<void> _onBackgroundNotificationResponse(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();

  final localNotifications = FlutterLocalNotificationsPlugin();
  try {
    await localNotifications.cancel(9999);
  } catch (_) {}

  if (response.payload == null) return;
  Map<String, dynamic> data;
  try {
    data = jsonDecode(response.payload!) as Map<String, dynamic>;
  } catch (_) {
    return;
  }

  if (response.actionId == 'decline_call') {
    await _declineCallHeadless(data);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("PNS: Handling background FCM message: ${message.messageId}, type: ${message.data['type']}");
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }

  final String? type = message.data['type']?.toString();
  final String content = (message.data['content'] ?? message.notification?.body ?? '').toString();

  if (type == 'CALL_CANCELLED' ||
      type == 'call:cancel' ||
      type == 'call:decline' ||
      type == 'call:end' ||
      type == 'MISSED_CALL' ||
      content.contains('Missed') ||
      content.contains('Call ended')) {
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await localNotifications.initialize(initSettings);

    try {
      await localNotifications.cancel(9999);
    } catch (_) {}

    if (type == 'CALL_CANCELLED' || type == 'call:cancel' || type == 'MISSED_CALL' || content.contains('Missed')) {
      PushNotificationService.showMissedCallNotification(message.data);
    }
    return;
  }

  if (type == 'INCOMING_CALL' || type == 'call:incoming') {
    PushNotificationService.showBackgroundCallNotification(message.data);
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<ByteArrayAndroidBitmap?> _getLargeIcon(String? imageUrl, String senderName) async {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      try {
        String url = imageUrl.trim();
        if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('data:image')) {
          if (url.startsWith('/')) url = url.substring(1);
          url = 'https://s3.ap-south-1.amazonaws.com/livepoised/$url';
        }

        Uint8List? rawBytes;
        if (url.startsWith('http://') || url.startsWith('https://')) {
          final request = await HttpClient().getUrl(Uri.parse(url)).timeout(const Duration(seconds: 4));
          final response = await request.close();
          if (response.statusCode == 200) {
            final bytes = await response.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
            if (bytes.isNotEmpty) rawBytes = Uint8List.fromList(bytes);
          }
        } else if (url.startsWith('data:image')) {
          final base64Str = url.split(',').last;
          final bytes = base64Decode(base64Str);
          if (bytes.isNotEmpty) rawBytes = bytes;
        }

        if (rawBytes != null) {
          final cropped = await _createCircularAvatarFromBytes(rawBytes);
          if (cropped != null) return cropped;
        }
      } catch (e) {
        print('PNS: Error fetching profile image for largeIcon: $e');
      }
    }

    return await _generateInitialAvatar(senderName);
  }

  static Future<ByteArrayAndroidBitmap?> _generateInitialAvatar(String name) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 192, 192));

      final paint = Paint()
        ..color = const Color(0xFF0F766E) // LivePoised teal brand color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(96, 96), 96, paint);

      final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'C';
      final textPainter = TextPainter(
        text: TextSpan(
          text: initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 96,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(96 - textPainter.width / 2, 96 - textPainter.height / 2),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(192, 192);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return ByteArrayAndroidBitmap(byteData.buffer.asUint8List());
      }
    } catch (e) {
      print('PNS: Error generating initial avatar: $e');
    }
    return null;
  }

  static Future<ByteArrayAndroidBitmap?> _createCircularAvatarFromBytes(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 192, targetHeight: 192);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 192, 192));

      final path = Path()..addOval(const Rect.fromLTWH(0, 0, 192, 192));
      canvas.clipPath(path);

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        const Rect.fromLTWH(0, 0, 192, 192),
        Paint(),
      );

      final picture = recorder.endRecording();
      final resultImg = await picture.toImage(192, 192);
      final byteData = await resultImg.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return ByteArrayAndroidBitmap(byteData.buffer.asUint8List());
      }
    } catch (e) {
      print('PNS: Error creating circular avatar: $e');
    }
    return ByteArrayAndroidBitmap(bytes);
  }

  static Future<void> showBackgroundCallNotification(Map<String, dynamic> data) async {
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await localNotifications.initialize(initSettings);

    final String senderFullName = data['senderFullName'] ?? data['sender'] ?? 'Incoming Call';
    final String? senderImage = data['senderImage'];
    final largeIcon = await _getLargeIcon(senderImage, senderFullName);

    final androidDetails = AndroidNotificationDetails(
      'incoming_call_v3_channel',
      'Incoming Call Notifications',
      channelDescription: 'Ringing incoming call notification banner with action buttons',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      playSound: true,
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      largeIcon: largeIcon,
      actions: const [
        AndroidNotificationAction(
          'decline_call',
          'Decline',
          titleColor: Color(0xFFEF4444),
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'accept_call',
          'Accept',
          titleColor: Color(0xFF10B981),
          showsUserInterface: true,
        ),
      ],
      icon: '@mipmap/ic_launcher',
    );

    final bool isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;

    final payload = jsonEncode(data);

    await localNotifications.show(
      9999,
      senderFullName,
      'Incoming ${isVideo ? "Video" : "Voice"} Call',
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  static Future<void> showMissedCallNotification(Map<String, dynamic> data) async {
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await localNotifications.initialize(initSettings);

    // 1. DISMISS INCOMING CALL BANNER (ID 9999) IMMEDIATELY!
    try {
      await localNotifications.cancel(9999);
    } catch (_) {}

    final String senderFullName = data['senderFullName'] ?? data['sender'] ?? 'User';
    final bool isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;
    final String sender = data['sender'] ?? '';

    final payload = jsonEncode({
      'type': 'MISSED_CALL',
      'sender': sender,
      'senderFullName': senderFullName,
      'isVideo': isVideo,
    });

    const androidDetails = AndroidNotificationDetails(
      'missed_call_channel',
      'Missed Call Notifications',
      channelDescription: 'Notifications for missed incoming voice and video calls',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.missedCall,
      actions: [
        AndroidNotificationAction(
          'call_back',
          'Call Back',
          titleColor: Color(0xFF10B981),
          showsUserInterface: true,
        ),
      ],
      icon: '@mipmap/ic_launcher',
    );

    await localNotifications.show(
      7777,
      'Missed Call',
      'Missed ${isVideo ? "video" : "voice"} call from $senderFullName',
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> initialize() async {
    print('PNS: Starting initialization');
    if (Firebase.apps.isEmpty) {
      print('PNS: Firebase app is not initialized. Skipping PushNotificationService initialization.');
      return;
    }
    
    // Register background handler
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      print('PNS Warning: Could not register onBackgroundMessage: $e');
    }

    // 1. Request permissions
    try {
      print('PNS: Requesting FCM permission...');
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      }
      try {
        final token = await _fcm.getToken();
        print('PNS: FCM Token registered -> $token');
        if (token != null) {
          _syncTokenToBackend(token);
        }
      } catch (e) {
        print('PNS Warning: Could not get FCM token: $e');
      }

      _fcm.onTokenRefresh.listen((newToken) {
        print('PNS: FCM Token refreshed -> $newToken');
        _syncTokenToBackend(newToken);
      });
    } catch (e) {
      print('PNS Warning: FCM requestPermission error: $e');
    }

    // 2. Initialize Local Notifications
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            'incoming_call',
            actions: [
              DarwinNotificationAction.plain(
                'accept_call',
                'Accept',
                options: {DarwinNotificationActionOption.foreground},
              ),
              // No `.foreground` option: iOS launches the app in the
              // background to run this action without bringing the UI up.
              DarwinNotificationAction.plain(
                'decline_call',
                'Decline',
                options: {DarwinNotificationActionOption.destructive},
              ),
            ],
            options: {DarwinNotificationCategoryOption.customDismissAction},
          ),
        ],
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      print('PNS: Initializing local notifications...');
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          dismissCallNotification();
          if (response.actionId == 'accept_call') {
            if (response.payload != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(response.payload!);
                if (Get.isRegistered<LiveKitService>()) {
                  Get.find<LiveKitService>().acceptCallWithData(
                    roomId: data['roomId'],
                    caller: data['sender'],
                    isVideo: data['isVideo'] == 'true' || data['isVideo'] == true,
                  );
                } else {
                  // Cold start: this callback can fire before InitialBinding
                  // has registered LiveKitService. Persist the accept intent
                  // so InitialBinding joins the call directly once it boots,
                  // instead of falling back to the ringing screen.
                  _persistPendingAcceptAction(data);
                }
              } catch (_) {}
            }
          } else if (response.actionId == 'decline_call') {
            if (Get.isRegistered<LiveKitService>()) {
              Get.find<LiveKitService>().declineCall();
            } else if (response.payload != null) {
              try {
                _declineCallHeadless(jsonDecode(response.payload!));
              } catch (_) {}
            }
          } else if (response.actionId == 'call_back') {
            if (response.payload != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(response.payload!);
                final sender = data['sender'] as String?;
                final isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;
                if (sender != null && Get.isRegistered<LiveKitService>()) {
                  Get.find<LiveKitService>().startCall(sender, withVideo: isVideo);
                }
              } catch (_) {}
            }
          } else if (response.payload != null) {
            try {
              final Map<String, dynamic> data = jsonDecode(response.payload!);
              handleNavigation(data);
            } catch (_) {}
          }
        },
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );
    } catch (e) {
      print('PNS Warning: Local notifications initialize error: $e');
    }

    print('PNS: Setting up FCM message listeners...');
    try {
      // 3. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        RemoteNotification? notification = message.notification;

        final String? type = message.data['type']?.toString();
        final String content = (message.data['content'] ?? message.notification?.body ?? '').toString();

        if (type == 'CALL_CANCELLED' ||
            type == 'call:cancel' ||
            type == 'call:decline' ||
            type == 'call:end' ||
            type == 'MISSED_CALL' ||
            content.contains('Missed') ||
            content.contains('Call ended')) {
          dismissCallNotification();
          if (Get.isRegistered<LiveKitService>()) {
            Get.find<LiveKitService>().handleCallCancelledLocally();
          }
          return;
        }

        if (type == 'INCOMING_CALL' || type == 'call:incoming') {
          // Foreground: DO NOT show local push notification card (avoid duplicate notification over full-screen UI).
          // Only update LiveKit state and navigate to /incoming-call full-screen ringing UI.
          if (Get.isRegistered<LiveKitService>()) {
            final livekit = Get.find<LiveKitService>();
            livekit.currentRoomId.value = message.data['roomId'];
            livekit.callerUsername.value = message.data['sender'];
            livekit.remoteUserFullName.value = message.data['senderFullName'] ?? message.data['sender'];
            livekit.remoteUserProfileImage.value = message.data['senderImage'];
            livekit.incomingIsVideo.value = message.data['isVideo'] == 'true' || message.data['isVideo'] == true;
            livekit.callState.value = callStateRinging;
          }
          if (Get.currentRoute != '/incoming-call' && Get.currentRoute != '/active-call') {
            Get.toNamed('/incoming-call');
          }
        } else if (notification != null) {
          _showLocalNotification(notification, message.data);
        }
      });

      // 4. Handle Notification Click when App is in Background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification clicked (Background stage)');
        handleNavigation(message.data);
      });

      // 5. Check for Terminated State Launch
      _fcm.getInitialMessage().then((RemoteMessage? initialMessage) {
        if (initialMessage != null) {
          print('Notification clicked (Terminated stage)');
          handleNavigation(initialMessage.data);
        }
      }).catchError((e) {
        print('PNS Error: Failed to get initial message: $e');
      });
    } catch (e) {
      print('PNS Warning: FCM listeners setup error: $e');
    }
    
    print('PNS: Initialization complete');
  }

  Future<void> showCallNotification({
    required String roomId,
    required String sender,
    required String senderFullName,
    required bool isVideo,
    String? senderImage,
  }) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    final largeIcon = await _getLargeIcon(senderImage, senderFullName);

    final androidDetails = AndroidNotificationDetails(
      'incoming_call_v3_channel',
      'Incoming Call Notifications',
      channelDescription: 'Ringing incoming call notification banner with action buttons',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      playSound: true,
      ongoing: true,
      autoCancel: false,
      visibility: NotificationVisibility.public,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      largeIcon: largeIcon,
      actions: const [
        AndroidNotificationAction(
          'decline_call',
          'Decline',
          titleColor: Color(0xFFEF4444),
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'accept_call',
          'Accept',
          titleColor: Color(0xFF10B981),
          showsUserInterface: true,
        ),
      ],
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'incoming_call',
        presentSound: true,
      ),
    );

    final payload = jsonEncode({
      'type': 'INCOMING_CALL',
      'roomId': roomId,
      'sender': sender,
      'senderFullName': senderFullName,
      'isVideo': isVideo,
      'senderImage': senderImage,
    });

    print('PNS: Showing local call notification for $senderFullName ($roomId)');
    await _localNotifications.show(
      9999,
      senderFullName.isNotEmpty ? senderFullName : sender,
      'Incoming ${isVideo ? "Video" : "Voice"} Call',
      details,
      payload: payload,
    );
  }

  void dismissCallNotification() {
    try {
      _localNotifications.cancel(9999);
    } catch (_) {}
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

    print('Directing navigation for type: $type, data: $data');

    if (type == null) return;

    switch (type) {
      case 'INCOMING_CALL':
      case 'call:incoming':
        final roomId = data['roomId'] as String?;
        final sender = data['sender'] as String?;
        final senderFullName = data['senderFullName'] as String?;
        final isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;
        final senderImage = data['senderImage'] as String?;

        if (roomId != null && sender != null) {
          if (Get.isRegistered<LiveKitService>()) {
            final livekit = Get.find<LiveKitService>();
            livekit.currentRoomId.value = roomId;
            livekit.callerUsername.value = sender;
            livekit.remoteUserFullName.value = senderFullName ?? sender;
            livekit.remoteUserProfileImage.value = senderImage;
            livekit.incomingIsVideo.value = isVideo;
            livekit.callState.value = callStateRinging;
          }
          if (Get.currentRoute != '/incoming-call' && Get.currentRoute != '/active-call') {
            Get.toNamed('/incoming-call');
          }
        }
        break;
      case 'CHAT_MESSAGE':
        if (referenceId != null) {
          Get.toNamed('/chat', arguments: referenceId.toString());
        }
        break;
      case 'ALLY_REQUEST':
      case 'CAREGIVER_REQUEST':
        Get.toNamed('/network');
        break;
      default:
        print('Unknown notification type: $type');
        break;
    }
  }

  static Future<void> _syncTokenToBackend(String token) async {
    try {
      print('PNS: Syncing FCM token to backend...');
      if (Get.isRegistered<NotificationService>()) {
        final ns = Get.find<NotificationService>();
        await ns.registerDeviceToken(fcmToken: token);
      } else {
        final ns = NotificationService();
        await ns.registerDeviceToken(fcmToken: token);
      }
    } catch (e) {
      print('PNS Error: Failed to sync FCM token to backend: $e');
    }
  }
}
