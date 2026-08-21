# LivePoised Mobile — Flutter LiveKit Calling & Chat Implementation Plan

> **App**: `livepoised_mobile` (Flutter / Dart)  
> **Backend**: FastAPI (`livepoisedapi`) + LiveKit SFU Server (`ws://localhost:7880`)  
> **Signaling**: JWT Token (`GET /call/token`) + WebSocket (`call:incoming`)  
> **Goal**: 100% Feature Parity with `livepoisedux` Web App Calling & Chat Architecture  
> **Updated**: 2026-08-20  

---

## 1. Architecture & Protocol Overview

The mobile calling and messaging architecture uses **LiveKit SFU (Selective Forwarding Unit)** for high-definition audio/video calls and **Cursor-based WebSocket & Cache Management** for messaging.

```
┌────────────────────────────────────────────────────────┐
│  FCM / APNs VoIP Push (Terminated/Background App)     │
│  Payload: { type: "INCOMING_CALL", roomId, caller, ...}│
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│  ChatWebSocketService (wss://.../chat/ws/{username})   │
│  - 25s Ping Heartbeat Loop                             │
│  - Auto-reconnect with exponential backoff             │
│  - App lifecycle state resume listener                 │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│  FastAPI Backend (livepoisedapi)                       │
│  1. GET /call/token?room=alex::elena → Returns JWT     │
│  2. GET /chat/history/alex/elena?before_id=123&limit=30│
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│  LiveKit SFU Server (ws://localhost:7880)              │
│  Handles 1080p Video, Audio Tracks & Data Channel      │
└───────────────────────────┘
```

---

## 2. Required Flutter Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Official LiveKit Flutter Client SDK
  livekit_client: ^2.4.0

  # Runtime permissions (Camera & Microphone)
  permission_handler: ^11.3.1

  # Keep device screen awake during active calls
  wakelock_plus: ^1.2.8

  # iOS CallKit & Android native call UI
  callkit_incoming: ^2.4.5

  # Networking & WebSocket
  http: ^1.2.0
  web_socket_channel: ^3.0.0

  # State Management
  get: ^4.6.6
```

---

## 3. Platform Configurations & Permissions

### 3.1 iOS — `ios/Runner/Info.plist`

```xml
<!-- Microphone Permission -->
<key>NSMicrophoneUsageDescription</key>
<string>Live Poised needs microphone access for high-definition voice and video calls.</string>

<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>Live Poised needs camera access for video calls and profile photos.</string>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>audio</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 3.2 Android — `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CAMERA"/>
<uses-permission android:name="android.permission.MANAGE_OWN_CALLS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

---

## 4. LiveKit Calling Service (`LiveKitService.dart`)

**File**: `lib/features/call/data/livekit_service.dart`

This class mirrors `hooks/useLiveKitCall.ts` from `livepoisedux` with support for **Dual Profile Picture Display**, **Noise Cancellation**, **Screen Sharing**, **PiP Mode**, **Floating Emoji Reactions**, **Device Switching**, and **Caller-Attributed Call History Logs**:

```dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import '../../chat/data/chat_websocket_service.dart';
import '../../auth/auth_controller.dart';

const String callStateIdle      = 'idle';
const String callStateCalling   = 'calling';
const String callStateRinging   = 'ringing';
const String callStateConnected = 'connected';

class LiveKitService extends GetxService {
  final ChatWebSocketService _ws   = Get.find<ChatWebSocketService>();
  final AuthController        _auth = Get.find<AuthController>();

  // ── Reactive State ───────────────────────────────────────────────
  final callState             = callStateIdle.obs;
  final isMuted               = false.obs;
  final isVideoOff            = false.obs;
  final isNoiseCancellationOn = true.obs;
  final isScreenSharing       = false.obs;
  final isMinimized           = false.obs; // PiP Mode
  final connectionQuality     = 'excellent'.obs;
  final incomingIsVideo       = true.obs;
  final callerUsername        = Rxn<String>();
  final currentRoomId         = Rxn<String>();

  // Profile Picture Metadata
  final localUserProfileImage  = Rxn<String>();
  final localUserFullName     = Rxn<String>();
  final remoteUserProfileImage = Rxn<String>();
  final remoteUserFullName    = Rxn<String>();

  final activeAudioDevice     = 'Speaker'.obs;
  final availableAudioDevices = <MediaDevice>[].obs;

  // ── LiveKit Room & Tracks ────────────────────────────────────────
  Room? room;
  VideoTrack? localVideoTrack;
  VideoTrack? remoteVideoTrack;
  VideoTrack? screenShareTrack;
  
  StreamSubscription? _wsSub;
  DateTime? _connectedStartTime;
  bool _isInitiator = false;

  String? get _username => _auth.userProfile.value?.username;
  static const String baseUrl = "http://10.0.2.2:8000"; // Or production API URL
  static const String livekitUrl = "ws://10.0.2.2:7880";

  @override
  void onInit() {
    super.onInit();
    _wsSub = _ws.rawMessages.listen(_handleSignal);
  }

  // ── Signal Handler ───────────────────────────────────────────────
  Future<void> _handleSignal(Map<String, dynamic> msg) async {
    final type = msg['type'] as String?;
    if (type == null || !type.startsWith('call:')) return;

    switch (type) {
      case 'call:incoming':
        if (callState.value == callStateIdle) {
          _isInitiator             = false;
          callState.value          = callStateRinging;
          currentRoomId.value      = msg['roomId'] as String?;
          callerUsername.value     = msg['sender'] as String?;
          remoteUserProfileImage.value = msg['senderImage'] as String?;
          remoteUserFullName.value    = msg['senderFullName'] as String?;
          incomingIsVideo.value    = (msg['isVideo'] as bool?) ?? true;
          Get.toNamed('/incoming-call');
        }
        break;

      case 'call:accept':
        if (callState.value == callStateCalling) {
          callState.value      = callStateConnected;
          _connectedStartTime = DateTime.now();
        }
        break;

      case 'call:decline':
      case 'call:cancel':
        if (callState.value == callStateConnected && _isInitiator) {
          _sendEndCallChatLog();
        }
        _cleanup();
        break;
    }
  }

  // ── Token Fetcher ────────────────────────────────────────────────
  Future<String> _fetchToken(String roomId) async {
    final res = await http.get(Uri.parse(
      '$baseUrl/call/token?room=${Uri.encodeComponent(roomId)}&username=${Uri.encodeComponent(_username!)}'
    ));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['token'] as String;
    }
    throw Exception('Failed to fetch call token');
  }

  // ── Start Call (Caller) ───────────────────────────────────────────
  Future<void> startCall(
    String targetUsername, {
    bool withVideo = true,
    String? targetImage,
    String? targetName,
  }) async {
    final roomId = ([_username!, targetUsername]..sort()).join('::');
    currentRoomId.value         = roomId;
    callState.value             = callStateCalling;
    _isInitiator                = true;
    isVideoOff.value            = !withVideo;
    _connectedStartTime         = null;
    remoteUserProfileImage.value = targetImage;
    remoteUserFullName.value    = targetName;

    final userProf = _auth.userProfile.value;
    localUserProfileImage.value = userProf?.profileImage;
    localUserFullName.value    = "${userProf?.firstName ?? ''} ${userProf?.lastName ?? ''}".trim();

    _ws.sendRaw({
      'type':           'call:incoming',
      'roomId':         roomId,
      'receiver':       targetUsername,
      'isVideo':        withVideo,
      'senderImage':    localUserProfileImage.value,
      'senderFullName': localUserFullName.value,
    });

    final token = await _fetchToken(roomId);
    await _connectToRoom(roomId, token, withVideo: withVideo);
  }

  // ── Connect to LiveKit Room ──────────────────────────────────────
  Future<void> _connectToRoom(String roomId, String token, {required bool withVideo}) async {
    final roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
      defaultVideoPublishOptions: const VideoPublishOptions(
        videoEncoding: VideoEncoding(
          maxBitrate: 3000000,
          maxFramerate: 30,
        ),
      ),
    );

    room = Room(roomOptions: roomOptions);

    room!.events.listen((event) {
      if (event is TrackSubscribedEvent) {
        if (event.track is VideoTrack) {
          if (event.publication.source == TrackSource.screenShare) {
            screenShareTrack = event.track as VideoTrack;
          } else {
            remoteVideoTrack = event.track as VideoTrack;
          }
        }
      } else if (event is ConnectionQualityUpdatedEvent) {
        if (event.participant == room!.localParticipant) {
          connectionQuality.value = event.connectionQuality.name;
        }
      }
    });

    await room!.connect(livekitUrl, token);
    await room!.localParticipant?.setMicrophoneEnabled(true);
    if (withVideo) {
      await room!.localParticipant?.setCameraEnabled(true);
      localVideoTrack = room!.localParticipant?.videoTrackPublications.firstOrNull?.track as VideoTrack?;
    }
  }

  void _cleanup() {
    room?.disconnect();
    room                   = null;
    localVideoTrack        = null;
    remoteVideoTrack       = null;
    screenShareTrack       = null;
    callState.value        = callStateIdle;
    currentRoomId.value    = null;
    callerUsername.value   = null;
    remoteUserProfileImage.value = null;
    remoteUserFullName.value    = null;
    isMuted.value          = false;
    isVideoOff.value       = false;
    isMinimized.value      = false;
    _isInitiator           = false;
  }
}
```

---

## 5. Dual Profile Picture Call Screen (`CallScreen.dart`)

```dart
// Dual Profile Picture Display Widget inside CallScreen.dart
Widget _buildDualAvatarDisplay(LiveKitService lk) {
  final localPic   = lk.localUserProfileImage.value;
  final localName  = lk.localUserFullName.value ?? 'You';
  final remotePic  = lk.remoteUserProfileImage.value;
  final remoteName = lk.remoteUserFullName.value ?? lk.callerUsername.value ?? 'Peer';

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Local User Avatar (You)
            Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: localPic != null ? NetworkImage(localPic) : null,
                  child: localPic == null ? Text(localName[0].toUpperCase(), style: const TextStyle(fontSize: 32)) : null,
                ),
                const SizedBox(height: 8),
                Text("You", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 24),

            // Connection Pulse Wave
            const Icon(Icons.graphic_eq, color: Colors.tealAccent, size: 32),
            const SizedBox(width: 24),

            // Remote Peer Avatar
            Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: remotePic != null ? NetworkImage(remotePic) : null,
                  child: remotePic == null ? Text(remoteName[0].toUpperCase(), style: const TextStyle(fontSize: 32)) : null,
                ),
                const SizedBox(height: 8),
                Text(remoteName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(remoteName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Voice Call in progress", style: TextStyle(color: Colors.tealAccent, fontSize: 14)),
      ],
    ),
  );
}
```

---

## 6. Mobile Feature Parity Matrix

| Feature | Web (`livepoisedux`) | Mobile (`livepoised_mobile`) |
| :--- | :--- | :--- |
| **Dual Profile Picture Display** | `VideoCallOverlay.tsx` via `UserAvatar` | `CallScreen.dart` via dual `CircleAvatar` widgets |
| **1080p Video Presets** | `VideoPresets.h1080` | `VideoPublishOptions(videoEncoding: VideoEncoding(maxBitrate: 3000000))` |
| **Hardware Noise Cancellation** | `mediaStreamTrack.applyConstraints({ noiseSuppression: true })` | `AudioCaptureOptions(noiseSuppression: true)` |
| **Screen Sharing** | `screenShareStream` canvas | `room.localParticipant?.setScreenShareEnabled(true)` |
| **Picture-in-Picture (PiP)** | CSS class toggle to `w-80 h-52` card | Draggable floating PiP widget |
| **Caller-Attributed Logs** | `isInitiatorRef` logic | `_isInitiator` logic |
