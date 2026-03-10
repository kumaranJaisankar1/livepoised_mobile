import 'package:get/get.dart';
import '../../data/datasource/chat_service.dart';
import '../../data/models/chat_connection.dart';

class ChatListController extends GetxController {
  final ChatService _chatService = ChatService();
  
  final connections = <ChatConnection>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConnections();
  }

  Future<void> fetchConnections() async {
    isLoading.value = true;
    try {
      final fetchedConnections = await _chatService.getConnections();
      connections.assignAll(fetchedConnections);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load connections');
    } finally {
      isLoading.value = false;
    }
  }
}
