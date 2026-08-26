import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:get_storage/get_storage.dart';

import '../../../core/services/push_notification_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/services/pip_service.dart';
import '../../../core/services/callkit_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/auth_controller.dart';
import '../../chat/data/datasource/chat_websocket_service.dart';

import '../../profile/presentation/controllers/profile_controller.dart';

const String callStateIdle = 'idle';
const String callStateCalling = 'calling';
const String callStateRinging = 'ringing';
const String callStateConnected = 'connected';

class FloatingEmoji {
  final String id;
  final String emoji;
  final String sender;

  FloatingEmoji({
    required this.id,
    required this.emoji,
    required this.sender,
  });
}

class LiveKitService extends GetxService with WidgetsBindingObserver {
  final ChatWebSocketService _ws = Get.find<ChatWebSocketService>();
  final AuthController _auth = Get.find<AuthController>();

  // ── Reactive State ───────────────────────────────────────────────
  final callState = callStateIdle.obs;
  final isMuted = false.obs;
  final isVideoOff = false.obs;
  final isNoiseCancellationOn = true.obs;
  final isScreenSharing = false.obs;
  final isMinimized = false.obs; // In-app mini window
  final isInNativePip = false.obs; // Real OS-level Picture-in-Picture (Android)
  StreamSubscription<bool>? _pipModeSub;
  StreamSubscription<String>? _pipActionSub;
  bool _pipPermissionPromptShown = false;
  final connectionQuality = 'excellent'.obs;
  final incomingIsVideo = true.obs;
  final callerUsername = Rxn<String>();
  final currentRoomId = Rxn<String>();

  // Dual Profile Metadata
  final localUserProfileImage = Rxn<String>();
  final localUserFullName = Rxn<String>();
  final remoteUserProfileImage = Rxn<String>();
  final remoteUserFullName = Rxn<String>();

  final activeAudioDevice = 'Speaker'.obs;
  final availableAudioDevices = <MediaDevice>[].obs;
  final floatingEmojis = <FloatingEmoji>[].obs;
  final callDurationSeconds = 0.obs;
  Timer? _callDurationTimer;
  Timer? _ringingTimer;

  // The ongoing-call notification refreshes every second (duration ticking
  // up), but the caller's avatar never changes for the life of one call —
  // fetched once here and reused, instead of re-downloading/re-decoding it
  // on every single tick.
  fln.AndroidBitmap<Object>? _ongoingCallIconBitmap;
  String? _ongoingCallIconForUrl;

  String get formattedCallDuration {
    final seconds = callDurationSeconds.value;
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    final hrs = mins ~/ 60;
    final remMins = mins % 60;
    if (hrs > 0) {
      return '${hrs.toString().padLeft(2, '0')}:${remMins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void handleCallCancelledLocally() {
    _cancelRingingTimer();
    if (callState.value == callStateRinging || callState.value == callStateCalling) {
      _cleanupAndPop();
    }
  }

  void _startDurationTimer() {
    _callDurationTimer?.cancel();
    callDurationSeconds.value = 0;
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callDurationSeconds.value++;
      _showOngoingCallNotification();
    });
  }

  void _startRingingTimer() {
    _ringingTimer?.cancel();
    _ringingTimer = Timer(const Duration(seconds: 30), () {
      logCall('LiveKitService: 30-second ringing timeout reached');
      _handleRingingTimeout();
    });
  }

  void _cancelRingingTimer() {
    _ringingTimer?.cancel();
    _ringingTimer = null;
  }

  void _handleRingingTimeout() {
    _cancelRingingTimer();
    final caller = callerUsername.value;
    final isVideo = incomingIsVideo.value;
    final callerName = remoteUserFullName.value ?? caller ?? 'User';

    if (caller != null) {
      _ws.sendRaw({
        'type': 'call:decline',
        'roomId': currentRoomId.value,
        'receiver': caller,
        'sender': _currentUsername,
      });
    }

    if (caller != null) {
      PushNotificationService.showMissedCallNotification({
        'sender': caller,
        'senderFullName': callerName,
        'isVideo': isVideo,
      });
    }

    _cleanupAndPop();
  }

  // ── LiveKit Room & Reactive Tracks ────────────────────────────────
  Room? room;
  final localVideoTrack = Rxn<VideoTrack>();
  final remoteVideoTrack = Rxn<VideoTrack>();
  final screenShareTrack = Rxn<VideoTrack>();

  StreamSubscription? _wsSub;
  DateTime? _connectedStartTime;
  bool _isInitiator = false;

  String? get _currentUsername => _auth.userProfile.value?.username;

  /// Waits (up to 6s) until AuthController knows whether this device is
  /// logged in. `/active-call` is registered with `AuthMiddleware`, which
  /// reads `isLoggedIn.value` synchronously the instant a navigation to it
  /// resolves — on a killed-app cold start (accepting a call, or "call
  /// back"), that navigation can fire before AuthController.checkAuthStatus()
  /// has finished its own async token-refresh call, so `isLoggedIn` is still
  /// `false` at that exact moment. The middleware then silently swaps the
  /// destination for '/login' instead of throwing — the call still connects
  /// underneath, but the UI gets stuck cycling through login/home and never
  /// actually shows the active-call screen. Waiting here (before navigating,
  /// not inside the middleware) fixes it at the source; already-logged-in
  /// callers (the common case) return immediately.
  Future<void> _waitForAuthReady() async {
    for (int i = 0; i < 60; i++) {
      if (_auth.isLoggedIn.value || _auth.isAuthChecked.value) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _wsSub = _ws.rawMessages.listen(_handleSignal);
    _pipModeSub = PipService().onModeChanged.listen((isInPip) {
      isInNativePip.value = isInPip;
      // Real system PiP shrinks whatever screen is currently on top —
      // if the call was minimized in-app (e.g. the user browsed elsewhere
      // while the FloatingCallOverlay bar showed), backgrounding into PiP
      // would otherwise squeeze that other screen into the tiny PiP window
      // instead of showing the call. Force the dedicated PiP-aware call
      // screen (ActiveCallView's isInNativePip branch) so PiP always shows
      // a call overview, never whatever the user happened to be looking at.
      if (isInPip && callState.value == callStateConnected && Get.currentRoute != '/active-call') {
        Get.toNamed('/active-call');
      }
    });
    _pipActionSub = PipService().onPipAction.listen((action) {
      if (action == 'end_call') {
        endCall();
      }
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelRingingTimer();
    _wsSub?.cancel();
    _pipModeSub?.cancel();
    _pipActionSub?.cancel();
    _cleanupAndPop();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ws.connect();
      PushNotificationService.syncFcmToken();
      // Only genuinely-ringing calls need a resume-triggered navigation —
      // `currentRoomId` stays set for the entire call (ringing AND
      // connected), so checking it here used to treat "call is connected"
      // the same as "call is ringing, show the incoming screen." The only
      // thing preventing that from misfiring on a connected call was the
      // Get.currentRoute check below, which races against the PiP-mode
      // listener (a separate, independently-timed native->Dart signal) —
      // both entering and exiting PiP cycle this app through `resumed`,
      // with no ordering guarantee against PiP's own route-settling. That
      // race was showing a duplicate incoming-call screen on top of an
      // already-connected call after expanding out of PiP.
      if (callState.value == callStateRinging) {
        if (Get.currentRoute != '/incoming-call' && Get.currentRoute != '/active-call') {
          Get.toNamed('/incoming-call');
        }
      } else if (callState.value == callStateIdle) {
        _checkActiveIncomingCall();
      }
    }
  }

  Future<void> _checkActiveIncomingCall() async {
    try {
      final response = await DioClient().fastAPI.get('/call/active-incoming');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['has_incoming'] == true) {
          final roomId = data['roomId'] as String?;
          final sender = data['sender'] as String?;
          final senderName = data['senderFullName'] as String?;
          final senderImage = data['senderImage'] as String?;
          final isVideo = data['isVideo'] == true || data['isVideo'] == 'true';

          if (roomId != null && sender != null && callState.value == callStateIdle) {
            _isInitiator = false;
            callState.value = callStateRinging;
            currentRoomId.value = roomId;
            callerUsername.value = sender;
            remoteUserFullName.value = senderName ?? sender;
            remoteUserProfileImage.value = senderImage;
            incomingIsVideo.value = isVideo;

            _startRingingTimer();

            if (Get.currentRoute != '/incoming-call' && Get.currentRoute != '/active-call') {
              Get.toNamed('/incoming-call');
            }
          }
        }
      }
    } catch (e) {
      logCall('LiveKitService: Error checking active incoming call on resume: $e');
    }
  }

  String? _getLocalProfileImage() {
    String? pic;
    if (Get.isRegistered<ProfileController>()) {
      final pc = Get.find<ProfileController>();
      if (pc.userImage.value.isNotEmpty) {
        pic = pc.userImage.value;
      } else if (pc.profileData.value?.userProfile.profileImageUrl?.isNotEmpty == true) {
        pic = pc.profileData.value?.userProfile.profileImageUrl;
      }
    }
    if (pic == null || pic.isEmpty) {
      try {
        if (Get.isRegistered<GetStorage>()) {
          final box = Get.find<GetStorage>();
          pic = box.read('user_image_cache');
        }
      } catch (_) {}
    }
    return pic;
  }

  Future<void> _fetchCallerProfileIfMissing(String username) async {
    if (username.isEmpty) return;
    try {
      final response = await DioClient().fastAPI.get('/users/profile/$username');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final fullName = data['fullName'] ?? data['name'] ?? data['username'] ?? username;
        final profileImg = data['profileImageUrl'] ?? data['image'] ?? data['avatar'];

        if (remoteUserFullName.value == null ||
            remoteUserFullName.value!.isEmpty ||
            remoteUserFullName.value == username ||
            remoteUserFullName.value == 'Incoming Call') {
          remoteUserFullName.value = fullName.toString();
        }

        if (remoteUserProfileImage.value == null || remoteUserProfileImage.value!.isEmpty) {
          if (profileImg != null && profileImg.toString().isNotEmpty) {
            remoteUserProfileImage.value = ApiEndpoints.resolveImageUrl(profileImg.toString());
          }
        }
      }
    } catch (e) {
      logCall('LiveKitService: Could not fetch caller profile for $username: $e');
    }
  }

  // ── Signal Handler ───────────────────────────────────────────────
  Future<void> _handleSignal(Map<String, dynamic> msg) async {
    final type = msg['type'] as String?;
    if (type == null || !type.startsWith('call:')) return;

    logCall('LiveKitService: Handled call signal -> $type');

    switch (type) {
      case 'call:incoming':
        if (callState.value == callStateIdle) {
          _isInitiator = false;
          callState.value = callStateRinging;
          currentRoomId.value = msg['roomId'] as String?;
          callerUsername.value = msg['sender'] as String?;
          remoteUserProfileImage.value = msg['senderImage'] as String?;
          remoteUserFullName.value = msg['senderFullName'] as String?;
          incomingIsVideo.value = (msg['isVideo'] as bool?) ?? true;

          if (callerUsername.value != null && callerUsername.value!.isNotEmpty) {
            _fetchCallerProfileIfMissing(callerUsername.value!);
          }

          localUserProfileImage.value = _getLocalProfileImage();
          final userProf = _auth.userProfile.value;
          final nameStr = userProf?.name ?? "${userProf?.givenName ?? ''} ${userProf?.familyName ?? ''}".trim();
          localUserFullName.value = nameStr.isNotEmpty ? nameStr : (_currentUsername ?? 'User');

          _startRingingTimer();

          final isForeground = WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

          if (isForeground) {
            // App is active in foreground: navigate to in-app incoming call UI directly
            if (Get.currentRoute != '/incoming-call' && Get.currentRoute != '/active-call') {
              Get.toNamed('/incoming-call');
            }
            // On iOS, also trigger CallKit for native status bar integration
            if (Platform.isIOS) {
              CallKitService().showIncomingCall(
                id: currentRoomId.value ?? '',
                roomId: currentRoomId.value ?? '',
                sender: callerUsername.value ?? '',
                senderFullName: remoteUserFullName.value ?? callerUsername.value ?? 'Incoming Call',
                isVideo: incomingIsVideo.value,
                senderImage: remoteUserProfileImage.value,
              );
            }
          } else {
            // App is in background/locked: trigger native CallKit / Android Call UI
            CallKitService().showIncomingCall(
              id: currentRoomId.value ?? '',
              roomId: currentRoomId.value ?? '',
              sender: callerUsername.value ?? '',
              senderFullName: remoteUserFullName.value ?? callerUsername.value ?? 'Incoming Call',
              isVideo: incomingIsVideo.value,
              senderImage: remoteUserProfileImage.value,
            );
          }
        }
        break;

      case 'call:accept':
        _cancelRingingTimer();
        if (callState.value == callStateCalling) {
          callState.value = callStateConnected;
          _connectedStartTime = DateTime.now();
          _startDurationTimer();
          _showOngoingCallNotification();
          _onCallConnected();
          try {
            WakelockPlus.enable();
          } catch (_) {}
        } else if (callState.value == callStateRinging) {
          // Call was answered on another device (e.g. Web). Dismiss incoming call UI.
          _cleanupAndPop();
        }
        break;

      case 'call:decline':
      case 'call:cancel':
        if (callState.value == callStateConnected && _isInitiator) {
          _sendEndCallChatLog();
        }
        _cleanupAndPop();
        break;

      case 'call:emoji':
        final emoji = msg['emoji'] as String?;
        final sender = msg['sender'] as String?;
        if (emoji != null && sender != null) {
          _triggerFloatingEmoji(emoji, sender);
        }
        break;

      case 'call:noise_toggle':
        final state = msg['enabled'] as bool?;
        if (state != null) {
          isNoiseCancellationOn.value = state;
        }
        break;
    }
  }

  // ── Request Permissions ──────────────────────────────────────────
  Future<bool> _requestPermissions({required bool withVideo}) async {
    try {
      try {
        await Permission.notification.request();
      } catch (_) {}

      final micCurrent = await Permission.microphone.status;
      if (!micCurrent.isGranted) {
        final micStatus = await Permission.microphone.request();
        if (micStatus.isPermanentlyDenied) {
          Get.snackbar('Permission Required', 'Microphone permission is required for calls. Please enable it in Settings.',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
          return false;
        }
      }

      if (withVideo) {
        final camCurrent = await Permission.camera.status;
        if (!camCurrent.isGranted) {
          final camStatus = await Permission.camera.request();
          if (camStatus.isPermanentlyDenied) {
            Get.snackbar('Permission Required', 'Camera permission is required for video calls. Please enable it in Settings.',
                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      logCall('LiveKitService: Permission request handled safely: $e');
      return true;
    }
  }

  // ── Token Fetcher ────────────────────────────────────────────────
  Future<String> _fetchToken(String roomId) async {
    final response = await DioClient().fastAPI.get(
      '/call/token',
      queryParameters: {
        'room': roomId,
        if (_currentUsername != null) 'username': _currentUsername,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data['token'] as String;
    }
    throw Exception('Failed to fetch call token from backend');
  }

  // ── Start Call (Caller) ───────────────────────────────────────────
  Future<void> startCall(
    String targetUsername, {
    bool withVideo = true,
    String? targetImage,
    String? targetName,
  }) async {
    if (_currentUsername == null) return;

    final hasPermissions = await _requestPermissions(withVideo: withVideo);
    if (!hasPermissions) return;

    final roomId = ([_currentUsername!, targetUsername]..sort()).join('::');
    currentRoomId.value = roomId;
    callState.value = callStateCalling;
    _isInitiator = true;
    isVideoOff.value = !withVideo;
    incomingIsVideo.value = withVideo;
    callerUsername.value = targetUsername;
    _connectedStartTime = null;
    remoteUserProfileImage.value = targetImage;
    remoteUserFullName.value = targetName ?? targetUsername;

    localUserProfileImage.value = _getLocalProfileImage();
    final userProf = _auth.userProfile.value;
    final nameStr = userProf?.name ?? "${userProf?.givenName ?? ''} ${userProf?.familyName ?? ''}".trim();
    localUserFullName.value = nameStr.isNotEmpty ? nameStr : (_currentUsername ?? 'User');

    // Same fire-and-forget ensureConnected() pattern as acceptCall(): a
    // "call back" from a killed-app cold start (tapping Call Back on a
    // missed-call notification) can reach here before ChatWebSocketService
    // has connected, which would otherwise silently drop this signal and
    // leave the callee's device never ringing.
    () async {
      final connected = await _ws.ensureConnected();
      if (connected) {
        _ws.sendRaw({
          'type': 'call:incoming',
          'roomId': roomId,
          'receiver': targetUsername,
          'sender': _currentUsername,
          'isVideo': withVideo,
          'senderImage': localUserProfileImage.value,
          'senderFullName': localUserFullName.value,
        });
      } else {
        logCall('LiveKitService: Could not deliver call:incoming — WebSocket never connected');
      }
    }();

    _startRingingTimer();

    // See acceptCall()'s identical wait: '/active-call' is behind
    // AuthMiddleware, which redirects to '/login' if isLoggedIn is still
    // false at the moment of navigation — a real risk on a killed-app
    // cold-start "call back" before checkAuthStatus() has finished.
    await _waitForAuthReady();
    Get.toNamed('/active-call');

    try {
      final token = await _fetchToken(roomId);
      await _connectToRoom(roomId, token, withVideo: withVideo);
    } catch (e) {
      Get.snackbar('Call Error', 'Could not connect to call: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      endCall();
    }
  }

  Future<void> acceptCallWithData({
    String? roomId,
    String? caller,
    bool? isVideo,
    String? callerFullName,
    String? callerImage,
  }) async {
    if (roomId != null) currentRoomId.value = roomId;
    if (caller != null) callerUsername.value = caller;
    if (isVideo != null) incomingIsVideo.value = isVideo;
    if (callerFullName != null && callerFullName.isNotEmpty) remoteUserFullName.value = callerFullName;
    if (callerImage != null && callerImage.isNotEmpty) remoteUserProfileImage.value = callerImage;
    await acceptCall();
  }

  // ── Accept Call (Receiver) ────────────────────────────────────────
  Future<void> acceptCall() async {
    final roomId = currentRoomId.value;
    final caller = callerUsername.value;
    if (roomId == null || caller == null) return;

    // Guards against double-accept: on a killed-app cold start, both the
    // `pending_call_action` marker (consumed by InitialBinding) and the
    // native `acceptCallHandle` callback can independently try to accept
    // the same call — whichever fires first wins, the other is a no-op.
    if (callState.value == callStateConnected || callState.value == callStateCalling) {
      return;
    }

    _cancelRingingTimer();

    final hasPermissions = await _requestPermissions(withVideo: incomingIsVideo.value);
    if (!hasPermissions) {
      declineCall();
      return;
    }

    callState.value = callStateConnected;
    _connectedStartTime = DateTime.now();
    _startDurationTimer();
    _showOngoingCallNotification();
    _onCallConnected();
    try {
      WakelockPlus.enable();
    } catch (_) {}

    // Fire-and-forget: on a killed-app cold start this can run before
    // ChatWebSocketService has connected (it only dials once
    // AuthController.checkAuthStatus() finishes, which is slower than this
    // accept path). sendRaw() alone would silently drop the frame, leaving
    // the caller's device stuck showing "Calling..." forever even though
    // this device already joined the room — ensureConnected() waits for
    // that connection instead. Not awaited here so it can't delay the
    // navigation below; the already-connected case (the common path)
    // resolves effectively instantly anyway.
    () async {
      final connected = await _ws.ensureConnected();
      if (connected) {
        _ws.sendRaw({
          'type': 'call:accept',
          'roomId': roomId,
          'receiver': caller,
          'sender': _currentUsername,
        });
      } else {
        logCall('LiveKitService: Could not deliver call:accept — WebSocket never connected');
      }
    }();

    await _waitForAuthReady();
    Get.offNamed('/active-call');

    try {
      final token = await _fetchToken(roomId);
      await _connectToRoom(roomId, token, withVideo: incomingIsVideo.value);
    } catch (e) {
      Get.snackbar('Call Error', 'Could not connect to room: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      endCall();
    }
  }

  // ── Decline Call ──────────────────────────────────────────────────
  void declineCall() {
    final roomId = currentRoomId.value;
    final caller = callerUsername.value;
    if (roomId != null && caller != null) {
      _ws.sendRaw({
        'type': 'call:decline',
        'roomId': roomId,
        'receiver': caller,
        'sender': _currentUsername,
        'isVideo': incomingIsVideo.value,
      });
    }
    _cleanupAndPop();
  }

  // ── End Call ──────────────────────────────────────────────────────
  void endCall() {
    final roomId = currentRoomId.value;
    String? peer = callerUsername.value;
    final myUser = _currentUsername ?? _auth.userProfile.value?.username;

    if ((peer == null || peer.isEmpty) && roomId != null && roomId.contains('::')) {
      final parts = roomId.split('::');
      if (parts.length == 2 && myUser != null && myUser.isNotEmpty) {
        peer = (parts[0] == myUser) ? parts[1] : parts[0];
      }
    }

    logCall('LiveKitService: Ending call in room $roomId with peer $peer (myUser: $myUser)');

    if (roomId != null && peer != null && peer.isNotEmpty) {
      _ws.sendRaw({
        'type': 'call:cancel',
        'roomId': roomId,
        'receiver': peer,
        'sender': myUser,
        'isVideo': incomingIsVideo.value,
      });

      if (callState.value == callStateConnected && _isInitiator) {
        _sendEndCallChatLog();
      }
    }
    _cleanupAndPop();
  }

  // ── Connect to LiveKit Room ──────────────────────────────────────
  Future<void> _connectToRoom(String roomId, String token, {required bool withVideo}) async {
    final livekitWsUrl = ApiEndpoints.livekitWsUrl;

    final roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
      defaultVideoPublishOptions: const VideoPublishOptions(
        videoEncoding: VideoEncoding(
          maxBitrate: 3000000,
          maxFramerate: 30,
        ),
      ),
      defaultAudioCaptureOptions: AudioCaptureOptions(
        noiseSuppression: isNoiseCancellationOn.value,
        echoCancellation: true,
        autoGainControl: true,
      ),
    );

    room = Room(roomOptions: roomOptions);

    room!.events.listen((event) {
      if (event is TrackSubscribedEvent) {
        if (event.track is VideoTrack) {
          if (event.publication.source == TrackSource.screenShareVideo || event.publication.source == TrackSource.screenShareAudio) {
            screenShareTrack.value = event.track as VideoTrack;
          } else {
            remoteVideoTrack.value = event.track as VideoTrack;
          }
        } else if (event.track is AudioTrack) {
          try {
            event.track.start();
          } catch (_) {}
        }
      } else if (event is TrackUnsubscribedEvent) {
        if (event.track == remoteVideoTrack.value) {
          remoteVideoTrack.value = null;
        } else if (event.track == screenShareTrack.value) {
          screenShareTrack.value = null;
        }
      } else if (event is TrackPublishedEvent || event is TrackUnmutedEvent || event is TrackMutedEvent) {
        _syncTracks();
      } else if (event is DataReceivedEvent) {
        try {
          final str = utf8.decode(event.data);
          final parsed = jsonDecode(str);
          if (parsed is Map && parsed['type'] == 'reaction') {
            final emoji = parsed['emoji'] as String?;
            final sender = parsed['sender'] as String? ?? event.participant?.identity ?? 'Peer';
            if (emoji != null) {
              _triggerFloatingEmoji(emoji, sender);
            }
          }
        } catch (_) {}
      } else if (event is ParticipantDisconnectedEvent) {
        endCall();
      } else if (event is RoomDisconnectedEvent) {
        endCall();
      }
    });

    await room!.connect(livekitWsUrl, token);
    await fetchAudioDevices();
    _syncTracks();

    await room!.localParticipant?.setMicrophoneEnabled(true);
    if (withVideo) {
      await room!.localParticipant?.setCameraEnabled(true);
      final pub = room!.localParticipant?.videoTrackPublications.firstOrNull;
      if (pub?.track is VideoTrack) {
        localVideoTrack.value = pub!.track as VideoTrack;
      }
    }
  }

  void _syncTracks() {
    if (room == null) return;

    VideoTrack? activeRemoteVideo;
    VideoTrack? activeScreenShare;

    for (var participant in room!.remoteParticipants.values) {
      for (var pub in participant.videoTrackPublications) {
        if (pub.subscribed && pub.track != null && !pub.muted) {
          if (pub.source == TrackSource.screenShareVideo) {
            activeScreenShare = pub.track as VideoTrack;
          } else {
            activeRemoteVideo = pub.track as VideoTrack;
          }
        }
      }
      for (var pub in participant.audioTrackPublications) {
        if (pub.subscribed && pub.track != null) {
          try {
            pub.track?.start();
          } catch (_) {}
        }
      }
    }

    remoteVideoTrack.value = activeRemoteVideo;
    screenShareTrack.value = activeScreenShare;

    final localPub = room!.localParticipant?.videoTrackPublications.firstOrNull;
    if (localPub?.track is VideoTrack && !localPub!.muted && !isVideoOff.value) {
      localVideoTrack.value = localPub!.track as VideoTrack;
    } else {
      localVideoTrack.value = null;
    }
  }

  // ── Call Control Actions ──────────────────────────────────────────
  Future<void> toggleMute() async {
    if (room?.localParticipant == null) return;
    final newMute = !isMuted.value;
    await room!.localParticipant?.setMicrophoneEnabled(!newMute);
    isMuted.value = newMute;
  }

  Future<void> toggleVideo() async {
    if (room?.localParticipant == null) return;
    final newVideoOff = !isVideoOff.value;
    await room!.localParticipant?.setCameraEnabled(!newVideoOff);
    isVideoOff.value = newVideoOff;
    if (!newVideoOff) {
      final pub = room!.localParticipant?.videoTrackPublications.firstOrNull;
      if (pub?.track is VideoTrack) {
        localVideoTrack.value = pub!.track as VideoTrack;
      }
    } else {
      localVideoTrack.value = null;
    }
  }

  Future<void> toggleNoiseCancellation() async {
    final newState = !isNoiseCancellationOn.value;
    isNoiseCancellationOn.value = newState;
    final peer = callerUsername.value;
    if (peer != null) {
      _ws.sendRaw({
        'type': 'call:noise_toggle',
        'enabled': newState,
        'receiver': peer,
        'sender': _currentUsername,
      });
    }
  }

  Future<void> fetchAudioDevices() async {
    try {
      final devices = await Hardware.instance.audioOutputs();
      availableAudioDevices.assignAll(devices);
      if (devices.isNotEmpty) {
        final speaker = devices.firstWhereOrNull(
          (d) => d.label.toLowerCase().contains('speaker'),
        ) ?? devices.first;
        await selectAudioDevice(speaker);
      } else {
        await AudioManager.instance.setSpeakerOutputPreferred(true);
        activeAudioDevice.value = 'Speaker';
      }
    } catch (e) {
      logCall('LiveKitService: Error fetching audio devices: $e');
      activeAudioDevice.value = 'Speaker';
    }
  }

  Future<void> selectAudioDevice(MediaDevice device) async {
    try {
      if (device.label.toLowerCase().contains('speaker')) {
        await AudioManager.instance.setSpeakerOutputPreferred(true);
      } else {
        await AudioManager.instance.setSpeakerOutputPreferred(false);
      }
      await Hardware.instance.selectAudioOutput(device);
      activeAudioDevice.value = device.label.isNotEmpty ? device.label : 'Audio Device';
    } catch (e) {
      logCall('LiveKitService: Error selecting audio device: $e');
    }
  }

  Future<void> toggleScreenShare() async {
    if (room?.localParticipant == null) return;
    final newState = !isScreenSharing.value;
    try {
      if (newState) {
        // Android 14 requires an active mediaProjection-type foreground
        // service to already be running before MediaProjection capture
        // starts, or the OS throws a SecurityException at the native layer
        // that kills the whole app process — uncatchable here since it
        // doesn't propagate back through this Future. Must be awaited
        // before setScreenShareEnabled(true), not fired in parallel.
        final serviceStarted = await PipService().startScreenShareService();
        if (!serviceStarted) {
          throw Exception('Could not start screen-share foreground service');
        }

        isMinimized.value = true;
        if (Get.currentRoute == '/active-call') {
          Get.back();
        }
      }
      await room!.localParticipant?.setScreenShareEnabled(newState);
      isScreenSharing.value = newState;
      if (!newState) {
        await PipService().stopScreenShareService();
      }
    } catch (e) {
      logCall('Screen share permission error: $e');
      isScreenSharing.value = false;
      isMinimized.value = false;
      await PipService().stopScreenShareService();
      Get.snackbar(
        'Screen Share',
        'Screen capture permission was not granted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  void toggleMinimize() {
    final newMin = !isMinimized.value;
    logCall('LiveKitService: toggleMinimize -> isMinimized=$newMin (isInNativePip=${isInNativePip.value})');
    isMinimized.value = newMin;
    if (newMin) {
      if (Get.currentRoute == '/active-call') {
        // A call accepted straight from a killed-app push notification
        // navigates directly to /active-call as the very first route (see
        // InitialBinding._consumePendingCallAction) — nothing is pushed
        // underneath it. Get.back() in that case has no route left to
        // reveal, which is exactly the black screen reported when
        // minimizing right after that kind of cold-start accept. Falling
        // back to the home route keeps the call running (isMinimized/the
        // floating overlay are independent of navigation) while actually
        // showing something instead of an empty stack.
        final canPop = Get.key.currentState?.canPop() ?? false;
        if (canPop) {
          Get.back();
        } else {
          Get.offNamed('/');
        }
      }
    } else {
      if (Get.currentRoute != '/active-call') {
        Get.toNamed('/active-call');
      }
    }
  }

  void sendEmoji(String emoji) {
    final peer = callerUsername.value;
    if (_currentUsername != null) {
      try {
        final payload = jsonEncode({
          'type': 'reaction',
          'emoji': emoji,
          'sender': _currentUsername,
        });
        room?.localParticipant?.publishData(utf8.encode(payload), reliable: true);
      } catch (e) {
        logCall('LiveKitService: Error publishing reaction data: $e');
      }

      if (peer != null) {
        _ws.sendRaw({
          'type': 'call:emoji',
          'emoji': emoji,
          'receiver': peer,
          'sender': _currentUsername,
        });
      }

      _triggerFloatingEmoji(emoji, _currentUsername!);
    }
  }

  void _triggerFloatingEmoji(String emoji, String sender) {
    final item = FloatingEmoji(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      emoji: emoji,
      sender: sender,
    );
    floatingEmojis.add(item);
    Timer(const Duration(seconds: 3), () {
      floatingEmojis.removeWhere((e) => e.id == item.id);
    });
  }

  void _sendEndCallChatLog() {
    final peer = callerUsername.value;
    if (peer == null || _connectedStartTime == null) return;
    final durationSec = DateTime.now().difference(_connectedStartTime!).inSeconds;
    final mins = durationSec ~/ 60;
    final secs = durationSec % 60;
    final hrs = mins ~/ 60;
    final remMins = mins % 60;
    String durationStr = "";
    if (hrs > 0) {
      durationStr = " • ${hrs.toString().padLeft(2, '0')}:${remMins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
    } else {
      durationStr = " • ${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
    }
    _ws.sendMessage(
      "Call ended$durationStr",
      peer,
    );
  }

  final fln.FlutterLocalNotificationsPlugin _localNotifications = fln.FlutterLocalNotificationsPlugin();

  Future<void> _showOngoingCallNotification() async {
    // Hide persistent notification banner if user is actively viewing full-screen active call UI in foreground
    if (!isMinimized.value &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
        Get.currentRoute == '/active-call') {
      _cancelOngoingCallNotification();
      return;
    }

    try {
      final peerName = remoteUserFullName.value ?? callerUsername.value ?? 'Call';
      final durationStr = formattedCallDuration;
      final isVideo = incomingIsVideo.value;
      String? imageUrl = remoteUserProfileImage.value;

      fln.AndroidBitmap<Object>? largeIconBitmap = _ongoingCallIconBitmap;
      if (_ongoingCallIconForUrl != imageUrl) {
        try {
          largeIconBitmap = await PushNotificationService.getLargeIcon(imageUrl, peerName);
          _ongoingCallIconBitmap = largeIconBitmap;
          _ongoingCallIconForUrl = imageUrl;
        } catch (_) {}
      }

      // The icon fetch above is async network/decode work — if the call
      // ended (far end hung up, etc.) while it was in flight, cleanup
      // already cancelled notification 8888 by the time we get here. Without
      // this check, .show() below would silently recreate it right after
      // cancellation, leaving a stale "ongoing call" notification behind
      // even though the call is over.
      if (callState.value != callStateConnected) return;

      final androidDetails = fln.AndroidNotificationDetails(
        'active_call_channel_medium_v1',
        'Active Call Controls',
        channelDescription: 'Ongoing active call notification with live duration timer and End Call button',
        importance: fln.Importance.low,
        priority: fln.Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        icon: '@mipmap/ic_launcher_monochrome',
        color: const Color(0xFF0F766E),
        largeIcon: largeIconBitmap,
        actions: const [
          fln.AndroidNotificationAction(
            'end_call_action',
            'End Call',
            titleColor: Color.fromARGB(255, 239, 68, 68),
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );
      final details = fln.NotificationDetails(android: androidDetails, iOS: const fln.DarwinNotificationDetails());

      _localNotifications.show(
        8888,
        peerName,
        '$durationStr • ${isVideo ? 'Video Call' : 'Voice Call'}',
        details,
      );
    } catch (e) {
      logCall('LiveKitService: Error showing ongoing call notification: $e');
    }
  }

  void _cancelOngoingCallNotification() {
    try {
      _localNotifications.cancel(8888);
      _localNotifications.cancel(9999);
      _localNotifications.cancelAll();
    } catch (_) {}
  }

  void _onCallConnected() {
    // Defensive reset, not relied on for correctness elsewhere: if a
    // previous call's PiP transition didn't clean up perfectly and left
    // this stuck true, it would otherwise silently suppress
    // FloatingCallOverlay for this entire new call too (that overlay
    // deliberately hides itself while isInNativePip is true, so as not to
    // duplicate ActiveCallView's own PiP-specific layout). Every fresh
    // connected call should start from a known-clean PiP state; the real
    // native onPipModeChanged listener remains the source of truth once
    // the call is actually running.
    isInNativePip.value = false;

    CallKitService().endAllCalls();
    PipService().setCallActive(true);
    _startDurationTimer();
    _maybePromptPipPermission();
    _persistActiveCallMarker();
  }

  static const String _activeCallMarkerKey = 'active_call_marker';

  /// Lets a fresh app launch (after a crash or being killed mid-call) detect
  /// there was a call in progress and rejoin it, instead of just landing on
  /// the home screen with no memory the call ever happened. Consumed by
  /// InitialBinding._consumeActiveCallMarker.
  void _persistActiveCallMarker() {
    if (!Get.isRegistered<GetStorage>()) return;
    final roomId = currentRoomId.value;
    final peer = callerUsername.value;
    if (roomId == null || peer == null) return;
    Get.find<GetStorage>().write(_activeCallMarkerKey, {
      'roomId': roomId,
      'peer': peer,
      'isVideo': incomingIsVideo.value,
      'peerName': remoteUserFullName.value,
      'peerImage': remoteUserProfileImage.value,
      'connectedAt': DateTime.now().toIso8601String(),
    });
  }

  void _clearActiveCallMarker() {
    if (Get.isRegistered<GetStorage>()) {
      Get.find<GetStorage>().remove(_activeCallMarkerKey);
    }
  }

  /// Rejoins a call that was connected before the app was killed/crashed —
  /// fetches a fresh LiveKit token and reconnects to the same room, same as
  /// a normal accept. If the room/other party is gone, this fails gracefully
  /// the same way any other failed connect attempt does.
  Future<void> resumeActiveCall({
    required String roomId,
    required String peer,
    required bool isVideo,
    String? peerName,
    String? peerImage,
  }) async {
    if (callState.value == callStateConnected || callState.value == callStateCalling) return;
    currentRoomId.value = roomId;
    callerUsername.value = peer;
    incomingIsVideo.value = isVideo;
    if (peerName != null && peerName.isNotEmpty) remoteUserFullName.value = peerName;
    if (peerImage != null && peerImage.isNotEmpty) remoteUserProfileImage.value = peerImage;
    await acceptCall();
  }

  static const String _pipPromptShownKey = 'pip_permission_prompt_shown';

  Future<void> _maybePromptPipPermission() async {
    if (_pipPermissionPromptShown || !incomingIsVideo.value) return;
    if (Get.isRegistered<GetStorage>() && Get.find<GetStorage>().read(_pipPromptShownKey) == true) {
      return;
    }
    final pip = PipService();
    if (!await pip.isSupported()) return;
    if (await pip.isPermissionEnabled()) return;

    _pipPermissionPromptShown = true;
    if (Get.isRegistered<GetStorage>()) {
      Get.find<GetStorage>().write(_pipPromptShownKey, true);
    }
    Get.snackbar(
      'Enable Picture-in-Picture',
      'Turn on Picture-in-Picture so this call keeps playing when you switch apps.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 6),
      mainButton: TextButton(
        onPressed: () => pip.openSettings(),
        child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
    );
  }

  void _cleanupAndPop() {
    // Timed rather than left implicit — this is the "end call -> cleanup
    // actually terminates" interval from the performance audit. Logged
    // async since the WebRTC teardown itself is intentionally fire-and-
    // forget from a post-frame callback (kept that way to avoid blocking
    // the main thread / causing the black-screen-on-hangup bug fixed
    // earlier) — this only adds a timestamp on top of that, not an await.
    final endCallStartedAt = DateTime.now();

    _cancelOngoingCallNotification();
    _ongoingCallIconBitmap = null;
    _ongoingCallIconForUrl = null;
    CallKitService().endIncomingCall(currentRoomId.value ?? '');
    PipService().setCallActive(false);
    _clearActiveCallMarker();
    if (isScreenSharing.value) {
      isScreenSharing.value = false;
      PipService().stopScreenShareService();
    }
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
    callDurationSeconds.value = 0;

    // Safely exit call screens and return to wherever the user actually was
    // (chat, feed, wherever) — prevents _history.isNotEmpty assertion errors.
    // Previously this always did Get.offAllNamed('/'), which discards the
    // *entire* navigation stack and forces MainLayout/FeedController to
    // rebuild from scratch even when the call was answered from, say, the
    // middle of a chat screen — visible to the user as the app "reloading"
    // right after declining/ending a call. Popping just the call screen(s)
    // off the stack (when there's something underneath to reveal) fixes
    // that; offAllNamed stays as the fallback for when the call screen was
    // the only thing on the stack (e.g. cold-start accept from a killed app).
    try {
      final route = Get.currentRoute;
      if (route == '/incoming-call' || route == '/active-call') {
        final canPop = Get.key.currentState?.canPop() ?? false;
        if (canPop) {
          Get.until((r) => r.settings.name != '/incoming-call' && r.settings.name != '/active-call');
        } else {
          Get.offAllNamed('/');
        }
      }
    } catch (e) {
      logCall('LiveKitService: Navigation pop error: $e');
    }

    // Dispose WebRTC room and tracks on next frame to prevent black screen and main thread freeze
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        WakelockPlus.disable();
      } catch (_) {}
      room?.disconnect().then((_) {
        logCall('LiveKitService: end call -> cleanup complete took '
            '${DateTime.now().difference(endCallStartedAt).inMilliseconds}ms');
      });
      room = null;
      localVideoTrack.value = null;
      remoteVideoTrack.value = null;
      screenShareTrack.value = null;
      callState.value = callStateIdle;
      currentRoomId.value = null;
      callerUsername.value = null;
      remoteUserProfileImage.value = null;
      remoteUserFullName.value = null;
      localUserProfileImage.value = null;
      localUserFullName.value = null;
      isMuted.value = false;
      isVideoOff.value = false;
      isMinimized.value = false;
      isScreenSharing.value = false;
      _isInitiator = false;
    });
  }
}
