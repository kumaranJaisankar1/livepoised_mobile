import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';
import '../../data/datasource/chat_service.dart';
import '../../data/models/inbox_item.dart';

class ChatListController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthController _authController = Get.find<AuthController>();
  
  final inboxItems = <InboxItem>[].obs;
  final isLoading = false.obs;
  final isSearchActive = false.obs;
  final searchQuery = ''.obs;
  final searchTextController = TextEditingController();

  List<InboxItem> get filteredInboxItems {
    if (searchQuery.value.isEmpty) {
      return inboxItems;
    }
    final query = searchQuery.value.toLowerCase();
    return inboxItems.where((item) {
      final firstName = item.otherUserFirstName?.toLowerCase() ?? '';
      final lastName = item.otherUserLastName?.toLowerCase() ?? '';
      final username = item.otherUsername.toLowerCase();
      final fullName = '$firstName $lastName'.toLowerCase();
      
      return firstName.contains(query) || 
             lastName.contains(query) || 
             username.contains(query) ||
             fullName.contains(query);
    }).toList();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void toggleSearch() {
    isSearchActive.value = !isSearchActive.value;
    if (!isSearchActive.value) {
      clearSearch();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    searchTextController.clear();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

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
