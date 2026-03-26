import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';
import '../../data/datasource/chat_service.dart';
import '../../data/models/inbox_item.dart';

class ChatListController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthController _authController = Get.find<AuthController>();
  
  final inboxItems = <InboxItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInbox();
  }

  Future<void> fetchInbox() async {
    final username = _authController.userProfile.value?.username;
    if (username == null) return;

    isLoading.value = true;
    try {
      final fetchedInbox = await _chatService.getInbox(username);
      inboxItems.assignAll(fetchedInbox);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load inbox');
    } finally {
      isLoading.value = false;
    }
  }
}
