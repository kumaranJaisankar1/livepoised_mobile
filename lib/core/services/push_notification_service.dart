import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../features/call/data/livekit_service.dart';
import '../../features/notification/data/services/notification_service.dart';
import '../../features/chat/data/models/inbox_item.dart';
import '../../features/chat/presentation/controllers/chat_controller.dart';
import '../constants/api_endpoints.dart';
import 'callkit_service.dart';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  if (response.actionId == 'end_call_action') {
    try {
      final localNotifications = FlutterLocalNotificationsPlugin();
      await localNotifications.cancel(8888);
      await localNotifications.cancel(9999);
    } catch (_) {}
    await CallKitService().endAllCalls();
    if (Get.isRegistered<LiveKitService>()) {
      Get.find<LiveKitService>().endCall();
    } else {
      await GetStorage.init();
      await GetStorage().write('pending_call_action', {'action': 'end'});
    }
    return;
  } else if (response.actionId == 'call_back') {
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        final sender = data['sender'] as String?;
        final isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;
        if (sender != null && sender.isNotEmpty) {
          if (Get.isRegistered<LiveKitService>()) {
            Get.find<LiveKitService>().startCall(
              sender,
              withVideo: isVideo,
              targetName: data['senderFullName'] as String?,
              targetImage: data['senderImage'] as String?,
            );
          } else {
            await GetStorage.init();
            final box = GetStorage();
            await box.write('pending_call_action', {
              'action': 'start',
              'targetUsername': sender,
              'isVideo': isVideo,
              'senderFullName': data['senderFullName'],
              'senderImage': data['senderImage'],
            });
          }
        }
      } catch (e) {
        print('PNS Error in background notification tap: $e');
      }
    }
  } else if (response.payload != null) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      final sender = (data['sender'] ?? data['senderUsername'] ?? data['otherUsername'] ?? data['referenceId'])?.toString();
      if (sender != null && sender.isNotEmpty) {
        await GetStorage.init();
        final box = GetStorage();
        await box.write('pending_call_action', {
          'action': 'open_chat',
          'targetUsername': sender,
          'senderFullName': data['senderFullName'],
          'senderImage': data['senderImage'],
        });
      }
    } catch (e) {
      print('PNS Error in background chat notification tap: $e');
    }
  }
}

/// Shared `onDidReceiveNotificationResponse` handler — the ONE place that
/// decides what a tapped notification action does while the app process is
/// alive. `flutter_local_notifications.initialize()` unconditionally
/// overwrites its previously-registered callback on every call (it's a
/// single shared native plugin instance backing every Dart-side
/// `FlutterLocalNotificationsPlugin()` object, confirmed by reading the
/// package source — `_onDidReceiveNotificationResponse = onDidReceive...`
/// with no null-check). Every `.initialize()` call in this file MUST pass
/// this exact function, or whichever one runs last silently disables
/// actions (like End Call) registered by an earlier call — this was a real,
/// confirmed bug: a chat/missed-call notification arriving mid-call could
/// clobber the End Call handler for the rest of the session.
void handleNotificationResponse(NotificationResponse response) {
  if (response.actionId == 'end_call_action') {
    try {
      final localNotifications = FlutterLocalNotificationsPlugin();
      localNotifications.cancel(8888);
      localNotifications.cancel(9999);
    } catch (_) {}
    CallKitService().endAllCalls();
    if (Get.isRegistered<LiveKitService>()) {
      Get.find<LiveKitService>().endCall();
    } else {
      GetStorage().write('pending_call_action', {'action': 'end'});
    }
    return;
  } else if (response.actionId == 'call_back') {
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        final sender = data['sender'] as String?;
        final isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;
        if (sender != null && sender.isNotEmpty) {
          if (Get.isRegistered<LiveKitService>()) {
            Get.find<LiveKitService>().startCall(
              sender,
              withVideo: isVideo,
              targetName: data['senderFullName'] as String?,
              targetImage: data['senderImage'] as String?,
            );
          } else {
            // Cold start: this callback can fire before InitialBinding has
            // registered LiveKitService (same race Accept/End Call already
            // guard against). Persist the intent so InitialBinding starts
            // the call once GetX/the Navigator are actually ready, instead
            // of calling startCall()/Get.toNamed() too early.
            GetStorage().write('pending_call_action', {
              'action': 'start',
              'targetUsername': sender,
              'isVideo': isVideo,
              'senderFullName': data['senderFullName'],
              'senderImage': data['senderImage'],
            });
          }
        }
      } catch (_) {}
    }
  } else if (response.payload != null) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      if (Get.isRegistered<LiveKitService>()) {
        PushNotificationService.handleNavigation(data);
      } else {
        // Cold start: handleNavigation's CHAT/MISSED_CALL/ALLY_REQUEST/
        // CAREGIVER_REQUEST branches call Get.toNamed/Get.offNamed directly,
        // which is the same class of race already fixed for call_back/
        // end_call_action above — the Navigator isn't attached yet if the
        // process was fully killed. INCOMING_CALL is safe without GetX
        // (CallKitService.showIncomingCall doesn't need it), so it's handled
        // directly; everything else is deferred via the pending-action
        // marker InitialBinding consumes once GetX/the Navigator are ready.
        final String? type = data['type'];
        switch (type) {
          case 'INCOMING_CALL':
          case 'call:incoming':
            PushNotificationService.handleNavigation(data);
            break;
          case 'CHAT_MESSAGE':
          case 'CHAT':
          case 'chat':
          case 'MISSED_CALL':
          case 'missed_call':
            final sender = (data['sender'] ?? data['senderUsername'] ?? data['otherUsername'] ?? data['referenceId'])?.toString();
            if (sender != null && sender.isNotEmpty) {
              GetStorage().write('pending_call_action', {
                'action': 'open_chat',
                'targetUsername': sender,
                'senderFullName': data['senderFullName'],
                'senderImage': data['senderImage'],
              });
            }
            break;
          case 'ALLY_REQUEST':
          case 'CAREGIVER_REQUEST':
            GetStorage().write('pending_call_action', {'action': 'open_network'});
            break;
          case 'NEURO_REMINDER':
            GetStorage().write('pending_call_action', {'action': 'open_neuro_wellness'});
            break;
        }
      }
    } catch (_) {}
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
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
    try {
      await localNotifications.cancel(8888);
      await localNotifications.cancel(9999);
      await localNotifications.cancelAll();
    } catch (_) {}

    final roomId = message.data['roomId']?.toString();
    if (roomId != null && roomId.isNotEmpty) {
      await CallKitService().endIncomingCall(roomId);
    }
    await CallKitService().endAllCalls();

    if (type == 'CALL_CANCELLED' || type == 'call:cancel' || type == 'MISSED_CALL' || content.contains('Missed')) {
      PushNotificationService.showMissedCallNotification(message.data);
    }
    return;
  }

  if (type == 'INCOMING_CALL' || type == 'call:incoming') {
    final roomId = message.data['roomId']?.toString() ?? '';
    // showIncomingCall resolves the S3 path / decodes base64 itself now —
    // pass the raw value straight through rather than duplicating that logic.
    await CallKitService().showIncomingCall(
      id: roomId,
      roomId: roomId,
      sender: message.data['sender']?.toString() ?? '',
      senderFullName: message.data['senderFullName']?.toString() ?? message.data['sender']?.toString() ?? 'Incoming Call',
      isVideo: message.data['isVideo'] == 'true' || message.data['isVideo'] == true,
      senderImage: message.data['senderImage']?.toString(),
    );
    return;
  }

  if (type == 'CHAT_MESSAGE' || type == 'CHAT') {
    PushNotificationService.showMessageNotification(message.data);
    return;
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<ByteArrayAndroidBitmap?> getLargeIcon(String? imageUrl, String senderName) async {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      try {
        final url = ApiEndpoints.resolveImageUrl(imageUrl);

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

      final cleanName = name.trim();
      String initials = '?';
      if (cleanName.isNotEmpty) {
        final parts = cleanName.split(RegExp(r'[\s._]+')).where((p) => p.isNotEmpty).toList();
        if (parts.length >= 2) {
          initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else {
          initials = cleanName.substring(0, cleanName.length >= 2 ? 2 : 1).toUpperCase();
        }
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: initials.length > 1 ? 72 : 96,
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

  static Future<void> showMissedCallNotification(Map<String, dynamic> data) async {
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher_monochrome');
    const initSettings = InitializationSettings(android: androidSettings);
    // Must always pass the full shared handler here (never a bare/no-handler
    // initialize()) — this can run in the same isolate as the main app (see
    // handleNotificationResponse's doc comment for why that matters).
    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 1. DISMISS INCOMING CALL BANNER (ID 9999) IMMEDIATELY!
    try {
      await localNotifications.cancel(9999);
    } catch (_) {}

    final String senderFullName = data['senderFullName'] ?? data['sender'] ?? 'User';
    final bool isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;
    final String sender = data['sender'] ?? '';
    final String? senderImage = data['senderImage'];

    AndroidBitmap<Object>? largeIconBitmap;
    try {
      largeIconBitmap = await getLargeIcon(senderImage, senderFullName);
    } catch (_) {}

    final payload = jsonEncode({
      'type': 'MISSED_CALL',
      'sender': sender,
      'senderFullName': senderFullName,
      'isVideo': isVideo,
      'senderImage': senderImage,
    });

    final androidDetails = AndroidNotificationDetails(
      'missed_call_channel',
      'Missed Call Notifications',
      channelDescription: 'Notifications for missed incoming voice and video calls',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.missedCall,
      largeIcon: largeIconBitmap,
      actions: const [
        AndroidNotificationAction(
          'call_back',
          'Call Back',
          titleColor: Color(0xFF10B981),
          showsUserInterface: true,
        ),
      ],
      // Android forces every status-bar icon into a flat silhouette from its
      // alpha channel, discarding color — using the full launcher icon here
      // renders as a solid blob. ic_launcher_monochrome is the proper
      // pre-made silhouette asset (Android 13+ themed-icon format) for
      // exactly this slot. `color` tints it (and the notification header)
      // with the brand teal — the closest thing to "color" this slot allows.
      icon: '@mipmap/ic_launcher_monochrome',
      color: const Color(0xFF0F766E),
    );

    await localNotifications.show(
      7777,
      'Missed Call',
      'Missed ${isVideo ? "video" : "voice"} call from $senderFullName',
      NotificationDetails(android: androidDetails),
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
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
    // (Incoming-call ringing UI is owned by CallKitService now — this plugin
    // instance only handles the missed-call notification's "Call Back"
    // action and general (non-call) notification navigation.)
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher_monochrome');
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
        onDidReceiveNotificationResponse: handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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
          if (Get.isRegistered<LiveKitService>()) {
            Get.find<LiveKitService>().handleCallCancelledLocally();
          }
          return;
        }

        if (type == 'CHAT_MESSAGE' || type == 'CHAT' || type == 'chat') {
          showMessageNotification(message.data);
          return;
        }

        if (type == 'INCOMING_CALL' || type == 'call:incoming') {
          // No-op here: while the app is alive/foregrounded, the live
          // ChatWebSocketService already delivers this same signal to
          // LiveKitService, which is what shows the CallKit incoming-call
          // UI (see CallKitService) — handling it a second time here would
          // risk a duplicate showCallkitIncoming call.
          return;
        } else if (notification != null) {
          _showLocalNotification(notification, message.data);
        } else if (content.isNotEmpty) {
          _showLocalNotification(
            RemoteNotification(
              title: message.data['title']?.toString() ?? message.data['senderFullName']?.toString() ?? 'LivePoised',
              body: content,
            ),
            message.data,
          );
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

  static void handleNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final dynamic referenceId = data['referenceId'];

    print('PNS: Navigating for notification type: $type, data: $data');

    switch (type) {
      case 'INCOMING_CALL':
      case 'call:incoming':
        final roomId = data['roomId'] as String?;
        final sender = data['sender'] as String?;
        final senderFullName = data['senderFullName'] as String?;
        final senderImage = data['senderImage'] as String?;
        final isVideo = data['isVideo'] == 'true' || data['isVideo'] == true;

        if (roomId != null && sender != null) {
          CallKitService().showIncomingCall(
            id: roomId,
            roomId: roomId,
            sender: sender,
            senderFullName: senderFullName ?? sender,
            isVideo: isVideo,
            senderImage: senderImage,
          );
        }
        break;
      case 'CHAT_MESSAGE':
      case 'CHAT':
      case 'chat':
      case 'MISSED_CALL':
      case 'missed_call':
        final sender = (data['sender'] ?? data['senderUsername'] ?? data['otherUsername'] ?? data['referenceId'] ?? referenceId)?.toString();
        final senderFullName = data['senderFullName']?.toString();
        final senderImage = data['senderImage']?.toString();

        if (sender != null && sender.isNotEmpty) {
          final inboxItem = InboxItem(
            otherUsername: sender,
            otherUserFirstName: senderFullName,
            otherUserImageUrl: senderImage,
            timestamp: DateTime.now(),
          );
          if (Get.currentRoute == '/chat') {
            Get.offNamed('/chat', arguments: inboxItem);
          } else {
            Get.toNamed('/chat', arguments: inboxItem);
          }
        }
        break;
      case 'ALLY_REQUEST':
      case 'CAREGIVER_REQUEST':
        Get.toNamed('/network');
        break;
      case 'NEURO_REMINDER':
        Get.toNamed('/neuro-wellness');
        break;
      default:
        print('Unknown notification type: $type');
        break;
    }
  }

  static bool isUserInConversation(String senderUsername) {
    if (senderUsername.isEmpty) return false;
    if (Get.isRegistered<ChatController>()) {
      final chatController = Get.find<ChatController>();
      final otherUser = chatController.otherUsername;
      if (otherUser != null && otherUser.toLowerCase() == senderUsername.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  static Future<void> showMessageNotification(Map<String, dynamic> data) async {
    final String senderUsername = (data['sender'] ?? data['senderUsername'] ?? '').toString();
    final String senderFullName = (data['senderFullName'] ?? data['senderName'] ?? senderUsername).toString();
    final String content = (data['content'] ?? data['body'] ?? data['message'] ?? 'New message').toString();
    String? senderImage = data['senderImage']?.toString();

    if (senderUsername.isEmpty) return;

    if (isUserInConversation(senderUsername)) {
      print('PNS: User is in active conversation with $senderUsername — suppressing push notification.');
      return;
    }

    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher_monochrome');
    const initSettings = InitializationSettings(android: androidSettings);

    await localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final largeIcon = await getLargeIcon(senderImage, senderFullName);

    final payload = jsonEncode({
      'type': 'CHAT_MESSAGE',
      'sender': senderUsername,
      'senderFullName': senderFullName,
      'senderImage': senderImage,
      'content': content,
    });

    final androidDetails = AndroidNotificationDetails(
      'chat_messages_channel_v1',
      'Message Notifications',
      channelDescription: 'Notifications for new direct chat messages',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.message,
      largeIcon: largeIcon,
      icon: '@mipmap/ic_launcher_monochrome',
      color: const Color(0xFF0F766E),
    );

    await localNotifications.show(
      senderUsername.hashCode,
      senderFullName.isNotEmpty ? senderFullName : senderUsername,
      content,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  static Future<void> clearNotificationsForUser(String username) async {
    if (username.isEmpty) return;
    try {
      final localNotifications = FlutterLocalNotificationsPlugin();
      await localNotifications.cancel(username.hashCode);
    } catch (e) {
      print('PNS: Error clearing notifications for user $username: $e');
    }
  }

  static Future<void> syncFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _syncTokenToBackend(token);
      }
    } catch (_) {}
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
