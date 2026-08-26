import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/theme_controller.dart';
import '../../features/auth/auth_service.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/chat/data/datasource/chat_websocket_service.dart';
import '../../features/call/data/livekit_service.dart';
import '../../features/notification/presentation/controllers/notification_controller.dart';
import '../../features/network/presentation/controllers/network_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/chat/data/models/inbox_item.dart';
import '../../features/chat/presentation/controllers/chat_list_controller.dart';
import '../services/callkit_service.dart';

const String _pendingCallActionKey = 'pending_call_action';
const String _activeCallMarkerKey = 'active_call_marker';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = Get.put(GetStorage());
    Get.put(ThemeController());
    Get.put(AuthService());
    Get.put(AuthController());
    final chatWs = Get.put(ChatWebSocketService());
    Get.put(ChatListController(), permanent: true);
    Get.put(LiveKitService());
    Get.put(NotificationController());
    Get.put(NetworkController());
    Get.put(ProfileController());
    chatWs.connect();
    CallKitService().init();

    _consumePendingCallAction(storage);
    _consumeActiveCallMarker(storage);
  }

  /// If the app was killed/crashed while a call was connected (e.g. the
  /// screen-share foreground-service crash), this reconnects to the same
  /// room on the next launch instead of silently losing the call — the user
  /// reopening the app should find themselves back in it, not on the home
  /// screen with no trace anything was happening.
  void _consumeActiveCallMarker(GetStorage storage) {
    final marker = storage.read(_activeCallMarkerKey);
    if (marker == null) return;
    storage.remove(_activeCallMarkerKey);

    if (marker is! Map) return;

    final connectedAtStr = marker['connectedAt'] as String?;
    final connectedAt = connectedAtStr != null ? DateTime.tryParse(connectedAtStr) : null;
    // Don't try to resume a call from more than 10 minutes ago — almost
    // certainly long since ended; avoids reconnecting into a stale room if
    // the app is reopened much later (next day, etc.).
    if (connectedAt == null || DateTime.now().difference(connectedAt) > const Duration(minutes: 10)) {
      return;
    }

    final roomId = marker['roomId'] as String?;
    final peer = marker['peer'] as String?;
    if (roomId == null || peer == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LiveKitService>().resumeActiveCall(
        roomId: roomId,
        peer: peer,
        isVideo: marker['isVideo'] == true,
        peerName: marker['peerName'] as String?,
        peerImage: marker['peerImage'] as String?,
      );
    });
  }

  /// Picks up an "accept" action recorded before GetX/LiveKitService existed
  /// (the notification response can arrive before InitialBinding runs on a
  /// cold start) and joins the call directly — skipping the ringing screen
  /// the user already answered from the notification.
  void _consumePendingCallAction(GetStorage storage) {
    final pending = storage.read(_pendingCallActionKey);
    if (pending == null) return;
    storage.remove(_pendingCallActionKey);

    if (pending is! Map) return;

    final action = pending['action'];
    if (action == 'accept') {
      final roomId = pending['roomId'] as String?;
      final sender = pending['sender'] as String?;
      if (roomId == null || sender == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lk = Get.find<LiveKitService>();
        lk.remoteUserFullName.value = pending['senderFullName'] as String?;
        lk.remoteUserProfileImage.value = pending['senderImage'] as String?;
        lk.acceptCallWithData(
          roomId: roomId,
          caller: sender,
          isVideo: pending['isVideo'] == true || pending['isVideo'] == 'true',
        );
      });
    } else if (action == 'start' || action == 'call_back') {
      final target = pending['targetUsername'] as String? ?? pending['sender'] as String?;
      if (target == null || target.isEmpty) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lk = Get.find<LiveKitService>();
        lk.startCall(
          target,
          withVideo: pending['isVideo'] == true || pending['isVideo'] == 'true',
          targetName: pending['senderFullName'] as String?,
          targetImage: pending['senderImage'] as String?,
        );
      });
    } else if (action == 'open_chat') {
      final target = pending['targetUsername'] as String? ?? pending['sender'] as String?;
      if (target == null || target.isEmpty) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final inboxItem = InboxItem(
          otherUsername: target,
          otherUserFirstName: pending['senderFullName'] as String?,
          otherUserImageUrl: pending['senderImage'] as String?,
          timestamp: DateTime.now(),
        );
        Get.toNamed('/chat', arguments: inboxItem);
      });
    } else if (action == 'open_network') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed('/network');
      });
    } else if (action == 'open_neuro_wellness') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed('/neuro-wellness');
      });
    } else if (action == 'end') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<LiveKitService>()) {
          Get.find<LiveKitService>().endCall();
        }
      });
    }
  }
}
