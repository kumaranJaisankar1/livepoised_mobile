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
    } else if (action == 'end') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<LiveKitService>()) {
          Get.find<LiveKitService>().endCall();
        }
      });
    }
  }
}
