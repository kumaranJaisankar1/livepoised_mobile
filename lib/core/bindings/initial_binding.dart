import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/theme_controller.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/chat/data/datasource/chat_websocket_service.dart';
import '../../features/call/data/livekit_service.dart';
import '../../features/notification/presentation/controllers/notification_controller.dart';
import '../../features/network/presentation/controllers/network_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../services/callkit_service.dart';

const String _pendingCallActionKey = 'pending_call_action';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = Get.put(GetStorage());
    Get.put(ThemeController());
    Get.put(AuthController());
    final chatWs = Get.put(ChatWebSocketService());
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

    if (pending is! Map || pending['action'] != 'accept') return;
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
  }
}
