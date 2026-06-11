import 'package:get/get.dart';
import '../../data/models/profile_models.dart';
import '../../data/services/profile_service.dart';
import '../../../auth/auth_controller.dart';
import '../../../feed/presentation/controllers/feed_controller.dart';

class BlockedUsersController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final AuthController _authController = Get.find<AuthController>();

  final isLoading = true.obs;
  final blockedUsers = <BlockedUser>[].obs;
  final unblockingUsernames = <String>{}.obs; // tracks currently unblocking usernames to show loading indicator individually

  String get currentUsername => _authController.userProfile.value?.username ?? '';

  @override
  void onInit() {
    super.onInit();
    loadBlockedUsers();
  }

  Future<void> loadBlockedUsers() async {
    if (currentUsername.isEmpty) {
      isLoading(false);
      return;
    }
    try {
      isLoading(true);
      final users = await _profileService.getBlockedUsers(currentUsername);
      blockedUsers.assignAll(users);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load blocked users: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> unblockUser(String blockedUsername) async {
    if (currentUsername.isEmpty) return;
    try {
      unblockingUsernames.add(blockedUsername);
      unblockingUsernames.refresh(); // trigger UI update
      
      final success = await _profileService.unblockUser(currentUsername, blockedUsername);
      if (success) {
        blockedUsers.removeWhere((user) => user.username == blockedUsername);
        Get.snackbar('Success', 'User unblocked successfully');
        
        // Revalidate the feed so their posts are visible again
        if (Get.isRegistered<FeedController>()) {
          Get.find<FeedController>().fetchPosts(refresh: true);
        }
      } else {
        Get.snackbar('Error', 'Failed to unblock user');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock user: $e');
    } finally {
      unblockingUsernames.remove(blockedUsername);
      unblockingUsernames.refresh(); // trigger UI update
    }
  }
}
