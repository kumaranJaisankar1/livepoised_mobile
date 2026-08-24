import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../features/call/data/livekit_service.dart';
import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';

const String _pendingCallActionKey = 'pending_call_action';

/// Declines an incoming call without any live GetX/app state — safe to call
/// from a background isolate/headless dispatch (Android fully terminated,
/// or the plugin's `onBackgroundMessage` on iOS) or before GetX has
/// finished bootstrapping. Signals the backend directly over REST, bypassing
/// the WebSocket-backed `LiveKitService` entirely.
Future<void> declineCallHeadless(Map<dynamic, dynamic> data) async {
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

    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrlFastAPI,
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
    print('CallKitService: Headless decline call failed: $e');
  }
}

/// Persists an "accept this call" marker that survives across isolates/cold
/// starts — works with no GetX/LiveKitService present. `InitialBinding`
/// consumes it once GetX has actually booted, joining the call directly
/// instead of requiring a second manual accept once the app is visible.
Future<void> persistPendingAcceptAction(Map<dynamic, dynamic> data) async {
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
    print('CallKitService: Failed to persist pending accept action: $e');
  }
}

/// Headless dispatch for CallKit events that arrive with no Flutter engine
/// running yet (app fully terminated). Must be a top-level/static function —
/// the plugin spins up its own isolate to invoke it, mirroring how
/// flutter_local_notifications' background response callback works.
@pragma('vm:entry-point')
Future<void> callkitBackgroundMessageHandler(CallEvent event) async {
  WidgetsFlutterBinding.ensureInitialized();
  switch (event) {
    case CallEventActionCallDecline(:final callKitParams):
      await declineCallHeadless(callKitParams.extra ?? {});
      break;
    case CallEventActionCallAccept(:final callKitParams):
      await persistPendingAcceptAction(callKitParams.extra ?? {});
      break;
    default:
      break;
  }
}

/// Owns the native incoming-call UI (CallKit on iOS, the plugin's own
/// full-screen UI on Android) for both platforms uniformly — replaces the
/// old per-platform custom ringing screen / heads-up notification actions.
class CallKitService {
  static final CallKitService _instance = CallKitService._internal();
  factory CallKitService() => _instance;
  CallKitService._internal();

  StreamSubscription<CallEvent?>? _eventSub;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _eventSub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);
    try {
      FlutterCallkitIncoming.onBackgroundMessage(callkitBackgroundMessageHandler);
    } catch (e) {
      print('CallKitService: Failed to register background message handler: $e');
    }

    if (Platform.isIOS) {
      _registerVoipTokenIfAvailable();
    }
    if (Platform.isAndroid) {
      try {
        FlutterCallkitIncoming.requestNotificationPermission({
          'title': 'Notification permission',
          'rationaleMessagePermission': 'Live Poised needs notification access to show incoming calls.',
        });
      } catch (_) {}
    }
  }

  Future<void> _registerVoipTokenIfAvailable() async {
    try {
      final token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      if (token != null && token.isNotEmpty) {
        await _syncVoipToken(token);
      }
    } catch (_) {}
  }

  Future<void> _syncVoipToken(String token) async {
    try {
      await DioClient().fastAPI.post('/notifications/voip-token/register', data: {
        'apns_voip_token': token,
      });
    } catch (e) {
      print('CallKitService: Failed to sync VoIP token: $e');
    }
  }

  void _handleEvent(CallEvent? event) {
    if (event == null) return;
    switch (event) {
      case CallEventActionDidUpdateDevicePushTokenVoip():
        _registerVoipTokenIfAvailable();
        break;
      case CallEventActionCallAccept(:final callKitParams):
        _onAccept(callKitParams);
        break;
      case CallEventActionCallDecline(:final callKitParams):
        _onDecline(callKitParams);
        break;
      case CallEventActionCallEnded(:final callKitParams):
        _onEnded(callKitParams);
        break;
      case CallEventActionCallTimeout():
        _onTimeout();
        break;
      default:
        break;
    }
  }

  void _onAccept(CallKitParams params) {
    final extra = params.extra ?? {};
    if (!Get.isRegistered<LiveKitService>()) {
      persistPendingAcceptAction(extra);
      return;
    }
    Get.find<LiveKitService>().acceptCallWithData(
      roomId: extra['roomId'] as String?,
      caller: extra['sender'] as String?,
      isVideo: extra['isVideo'] == true || extra['isVideo'] == 'true',
      callerFullName: extra['senderFullName'] as String?,
      callerImage: extra['senderImage'] as String?,
    );
  }

  void _onDecline(CallKitParams params) {
    if (Get.isRegistered<LiveKitService>()) {
      Get.find<LiveKitService>().declineCall();
    } else {
      declineCallHeadless(params.extra ?? {});
    }
  }

  bool _isProgrammaticDismissal = false;

  void _onEnded(CallKitParams params) {
    if (_isProgrammaticDismissal) return;
    if (Get.isRegistered<LiveKitService>()) {
      final lk = Get.find<LiveKitService>();
      // Only trigger endCall if the call was still in ringing or calling state —
      // do NOT terminate an already connected call when native CallKit UI dismisses!
      if (lk.callState.value == callStateRinging || lk.callState.value == callStateCalling) {
        lk.endCall();
      }
    }
  }

String stringToUuid(String input) {
  if (input.isEmpty) return '00000000-0000-0000-0000-000000000000';
  final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  if (uuidRegex.hasMatch(input)) {
    return input.toLowerCase();
  }
  final hex = md5.convert(utf8.encode(input)).toString();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
}

  void _onTimeout() {
    if (Get.isRegistered<LiveKitService>()) {
      Get.find<LiveKitService>().declineCall();
    }
  }

  /// Shows the native incoming-call UI. Converts any `id` or `roomId` into a
  /// valid 36-character hyphenated UUID required by CallKit on iOS.
  Future<void> showIncomingCall({
    required String id,
    required String roomId,
    required String sender,
    required String senderFullName,
    required bool isVideo,
    String? senderImage,
  }) async {
    final String uuid = stringToUuid(id.isNotEmpty ? id : roomId);
    String? safeAvatar;
    if (senderImage != null && senderImage.trim().isNotEmpty && !senderImage.startsWith('data:image')) {
      safeAvatar = await _downloadAndCacheAvatar(senderImage, uuid);
    }

    final params = CallKitParams(
      id: uuid,
      nameCaller: senderFullName.isNotEmpty ? senderFullName : sender,
      appName: 'Live Poised',
      avatar: safeAvatar,
      handle: isVideo ? 'Incoming Video Call' : 'Incoming Voice Call',
      type: isVideo ? 1 : 0,
      duration: 30000,
      extra: {
        'roomId': roomId,
        'sender': sender,
        'senderFullName': senderFullName,
        'senderImage': safeAvatar ?? '',
        'isVideo': isVideo,
      },
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        isShowCallID: true,
        backgroundColor: '#0F766E',
        actionColor: '#0F766E',
        textColor: '#FFFFFF',
        incomingCallNotificationChannelName: 'Incoming Calls',
        missedCallNotificationChannelName: 'Missed Calls',
        isShowFullLockedScreen: true,
      ),
      ios: const IOSParams(
        handleType: 'generic',
        supportsVideo: true,
        audioSessionMode: 'default',
      ),
    );
    try {
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (e) {
      print('CallKitService: Error presenting showCallkitIncoming: $e');
    }
  }

  /// Marks the call as actively connected once LiveKit media is flowing —
  /// updates iOS's native call representation (status bar pill, Phone app
  /// recents). No-op on Android beyond firing the callback event.
  Future<void> setConnected(String id) async {
    if (id.isEmpty) return;
    try {
      final String uuid = stringToUuid(id);
      await FlutterCallkitIncoming.setCallConnected(uuid);
    } catch (_) {}
  }

  /// Ends/dismisses the native call UI for `id` — call on every termination
  /// path (declined, cancelled, timed out, or a normal hangup).
  Future<void> endIncomingCall(String id) async {
    if (id.isEmpty) return;
    try {
      _isProgrammaticDismissal = true;
      final String uuid = stringToUuid(id);
      await FlutterCallkitIncoming.endCall(uuid);
    } catch (_) {} finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _isProgrammaticDismissal = false;
      });
    }
  }

  /// Dismisses all native CallKit notifications/UI.
  Future<void> endAllCalls() async {
    try {
      _isProgrammaticDismissal = true;
      await FlutterCallkitIncoming.endAllCalls();
    } catch (_) {} finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        _isProgrammaticDismissal = false;
      });
    }
  }

  static Future<String?> _downloadAndCacheAvatar(String imageUrl, String uuid) async {
    try {
      String url = imageUrl.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (url.startsWith('/')) url = url.substring(1);
        url = 'https://s3.ap-south-1.amazonaws.com/livepoised/$url';
      }

      final request = await HttpClient().getUrl(Uri.parse(url)).timeout(const Duration(seconds: 3));
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await response.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
        if (bytes.isNotEmpty) {
          final tempDir = Directory.systemTemp;
          final file = File('${tempDir.path}/call_avatar_$uuid.png');
          await file.writeAsBytes(bytes);
          return file.path;
        }
      }
    } catch (e) {
      print('CallKitService: Error downloading avatar for CallKit: $e');
    }
    return imageUrl;
  }
}
