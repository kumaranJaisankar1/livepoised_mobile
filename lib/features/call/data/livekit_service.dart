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
      print('LiveKitService: 30-second ringing timeout reached');
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

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _wsSub = _ws.rawMessages.listen(_handleSignal);
    _pipModeSub = PipService().onModeChanged.listen((isInPip) {
      isInNativePip.value = isInPip;
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
      // The native CallKit/incoming-call UI (see CallKitService) already
      // presents ringing calls regardless of app foreground state — nothing
      // to navigate to here on resume.
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

  // ── Signal Handler ───────────────────────────────────────────────
  Future<void> _handleSignal(Map<String, dynamic> msg) async {
    final type = msg['type'] as String?;
    if (type == null || !type.startsWith('call:')) return;

    print('LiveKitService: Handled call signal -> $type');

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
      await Permission.notification.request();
    } catch (_) {}

    final micStatus = await Permission.microphone.request();
    if (micStatus.isDenied || micStatus.isPermanentlyDenied) {
      Get.snackbar('Permission Required', 'Microphone permission is required for calls.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return false;
    }

    if (withVideo) {
      final camStatus = await Permission.camera.request();
      if (camStatus.isDenied || camStatus.isPermanentlyDenied) {
        Get.snackbar('Permission Required', 'Camera permission is required for video calls.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
        return false;
      }
    }
    return true;
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

    _ws.sendRaw({
      'type': 'call:incoming',
      'roomId': roomId,
      'receiver': targetUsername,
      'sender': _currentUsername,
      'isVideo': withVideo,
      'senderImage': localUserProfileImage.value,
      'senderFullName': localUserFullName.value,
    });

    _startRingingTimer();

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
  }) async {
    if (roomId != null) currentRoomId.value = roomId;
    if (caller != null) callerUsername.value = caller;
    if (isVideo != null) incomingIsVideo.value = isVideo;
    await acceptCall();
  }

  // ── Accept Call (Receiver) ────────────────────────────────────────
  Future<void> acceptCall() async {
    final roomId = currentRoomId.value;
    final caller = callerUsername.value;
    if (roomId == null || caller == null) return;

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

    _ws.sendRaw({
      'type': 'call:accept',
      'roomId': roomId,
      'receiver': caller,
      'sender': _currentUsername,
    });

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
      });
    }
    _cleanupAndPop();
  }

  // ── End Call ──────────────────────────────────────────────────────
  void endCall() {
    final roomId = currentRoomId.value;
    final peer = callerUsername.value;
    if (roomId != null && peer != null) {
      _ws.sendRaw({
        'type': 'call:cancel',
        'roomId': roomId,
        'receiver': peer,
        'sender': _currentUsername,
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
      print('LiveKitService: Error fetching audio devices: $e');
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
      print('LiveKitService: Error selecting audio device: $e');
    }
  }

  Future<void> toggleScreenShare() async {
    if (room?.localParticipant == null) return;
    final newState = !isScreenSharing.value;
    try {
      if (newState) {
        isMinimized.value = true;
        if (Get.currentRoute == '/active-call') {
          Get.back();
        }
      }
      await room!.localParticipant?.setScreenShareEnabled(newState);
      isScreenSharing.value = newState;
    } catch (e) {
      print('Screen share permission error: $e');
      isScreenSharing.value = false;
      isMinimized.value = false;
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
    isMinimized.value = newMin;
    if (newMin) {
      if (Get.currentRoute == '/active-call') {
        Get.back();
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
        print('LiveKitService: Error publishing reaction data: $e');
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

      fln.AndroidBitmap<Object>? largeIconBitmap;
      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        try {
          String url = imageUrl.trim();
          if (!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('data:image')) {
            if (url.startsWith('/')) url = url.substring(1);
            url = 'https://s3.ap-south-1.amazonaws.com/livepoised/$url';
          }
          if (url.startsWith('http://') || url.startsWith('https://')) {
            final request = await HttpClient().getUrl(Uri.parse(url)).timeout(const Duration(seconds: 3));
            final response = await request.close();
            if (response.statusCode == 200) {
              final bytes = await response.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
              if (bytes.isNotEmpty) {
                largeIconBitmap = fln.ByteArrayAndroidBitmap(Uint8List.fromList(bytes));
              }
            }
          }
        } catch (_) {}
      }

      final androidDetails = fln.AndroidNotificationDetails(
        'active_call_channel_v5',
        'Active Call Controls',
        channelDescription: 'Ongoing active call notification with live duration timer and End Call button',
        importance: fln.Importance.high,
        priority: fln.Priority.high,
        ongoing: true,
        autoCancel: false,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: largeIconBitmap,
        actions: const [
          fln.AndroidNotificationAction(
            'end_call_action',
            'End Call',
            titleColor: Color.fromARGB(255, 239, 68, 68),
            showsUserInterface: false,
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
      print('LiveKitService: Error showing ongoing call notification: $e');
    }
  }

  void _cancelOngoingCallNotification() {
    try {
      _localNotifications.cancel(8888);
    } catch (_) {}
  }

  void _onCallConnected() {
    CallKitService().setConnected(currentRoomId.value ?? '');
    PipService().setCallActive(true);
    _startDurationTimer();
    _maybePromptPipPermission();
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
    _cancelOngoingCallNotification();
    CallKitService().endIncomingCall(currentRoomId.value ?? '');
    PipService().setCallActive(false);
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
    callDurationSeconds.value = 0;
    try {
      WakelockPlus.disable();
    } catch (_) {}
    room?.disconnect();
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

    // Pop all call screens (/incoming-call, /active-call) from GetX navigation stack
    while (Get.currentRoute == '/incoming-call' || Get.currentRoute == '/active-call') {
      Get.back();
    }
  }
}
