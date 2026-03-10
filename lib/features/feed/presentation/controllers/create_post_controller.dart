import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/community_model.dart';
import '../../data/models/create_post_request.dart';
import '../../../auth/auth_controller.dart';
import '../../services/feed_service.dart';
import './feed_controller.dart';

class CreatePostController extends GetxController {
  final FeedService _feedService = FeedService();
  final AuthController _authController = Get.find<AuthController>();

  final communities = <CommunityModel>[].obs;
  final selectedCommunity = Rxn<CommunityModel>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final tags = <String>[].obs;
  final visibility = "public".obs;

  final isEditMode = false.obs;
  dynamic editingPostId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args.containsKey('post')) {
      final post = args['post'];
      isEditMode.value = true;
      editingPostId = post.id.toString();
      titleController.text = post.title;
      contentController.text = post.content;
      tags.assignAll(post.tags);
      visibility.value = post.visibility ?? "public";
    }
    fetchCommunities();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  Future<void> fetchCommunities() async {
    isLoading.value = true;
    try {
      final list = await _feedService.getCommunities();
      communities.assignAll(list);
      if (communities.isNotEmpty) {
        selectedCommunity.value = communities.first;
      }
    } catch (e) {
      print('Fetch Communities Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
    }
  }

  void removeTag(String tag) {
    tags.remove(tag);
  }

  Future<void> submitPost() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Title cannot be empty');
      return;
    }
    if (contentController.text.isEmpty) {
      Get.snackbar('Error', 'Content cannot be empty');
      return;
    }
    if (selectedCommunity.value == null) {
      Get.snackbar('Error', 'Please select a community');
      return;
    }

    isSubmitting.value = true;
    try {
      final username = _authController.userProfile.value?.username;
      if (username == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final request = CreatePostRequest(
        title: titleController.text,
        content: contentController.text,
        tags: tags.toList(),
        visibility: visibility.value,
        username: username,
        // authorImageUrl: _authController.userProfile.value?.profileImage,
      );

      bool success;
      if (isEditMode.value && editingPostId != null) {
        success = await _feedService.updatePost(editingPostId!, request);
      } else {
        success = await _feedService.createPost(selectedCommunity.value!.id, request);
      }

      if (success) {
        Get.back();
        Get.snackbar('Success', 'Post ${isEditMode.value ? 'updated' : 'created'} successfully');
        // Refresh feed
        Get.find<FeedController>().fetchPosts(refresh: true);
      } else {
        Get.snackbar('Error', 'Failed to ${isEditMode.value ? 'update' : 'create'} post');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
