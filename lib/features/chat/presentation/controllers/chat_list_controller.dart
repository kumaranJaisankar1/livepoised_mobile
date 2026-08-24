import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../auth/auth_controller.dart';
import '../../data/datasource/chat_service.dart';
import '../../data/datasource/chat_websocket_service.dart';
import '../../data/models/inbox_item.dart';

class ChatListController extends GetxController {
  final ChatService _chatService = ChatService();
  final AuthController _authController = Get.find<AuthController>();
  
  final inboxItems = <InboxItem>[].obs;
  final isLoading = false.obs;
  final isSearchActive = false.obs;
  final searchQuery = ''.obs;
  final searchTextController = TextEditingController();
  StreamSubscription? _wsSub;
  Worker? _profileWorker;

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

  int get totalUnreadCount => inboxItems.fold(0, (sum, item) => sum + (item.unreadCount ?? 0));

  @override
  void onClose() {
    _wsSub?.cancel();
    _profileWorker?.dispose();
    searchTextController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    fetchInbox();

    _profileWorker = ever(_authController.userProfile, (_) {
      fetchInbox();
    });

    if (Get.isRegistered<ChatWebSocketService>()) {
      _wsSub = Get.find<ChatWebSocketService>().messages.listen((_) {
        fetchInbox();
      });
    }
  }

  Future<void> fetchInbox() async {
    String? username = _authController.userProfile.value?.username;
    if (username == null || username.isEmpty) {
      if (Get.isRegistered<GetStorage>()) {
        final box = Get.find<GetStorage>();
        username = box.read('username') ?? box.read('user_username') ?? box.read('user')?['username'];
      }
    }
    if (username == null || username.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      username = _authController.userProfile.value?.username;
    }
    if (username == null || username.isEmpty) return;

    isLoading.value = true;
    try {
      final fetchedInbox = await _chatService.getInbox(username);
      fetchedInbox.sort((a, b) => (b.timestamp ?? DateTime.now()).compareTo(a.timestamp ?? DateTime.now()));
      inboxItems.assignAll(fetchedInbox);
    } catch (e) {
      print('ChatListController: Error fetching inbox: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
