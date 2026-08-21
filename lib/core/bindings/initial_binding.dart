import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/theme_controller.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/chat/data/datasource/chat_websocket_service.dart';
import '../../features/call/data/livekit_service.dart';
import '../../features/notification/presentation/controllers/notification_controller.dart';
import '../../features/network/presentation/controllers/network_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GetStorage());
    Get.put(ThemeController());
    Get.put(AuthController());
    final chatWs = Get.put(ChatWebSocketService());
    Get.put(LiveKitService());
    Get.put(NotificationController());
    Get.put(NetworkController());
    Get.put(ProfileController());
    chatWs.connect();
  }
}
