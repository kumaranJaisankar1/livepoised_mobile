import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/image_utils.dart';
import '../controllers/blocked_users_controller.dart';

class BlockedUsersView extends GetView<BlockedUsersController> {
  const BlockedUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerList();
        }

        if (controller.blockedUsers.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: controller.blockedUsers.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = controller.blockedUsers[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                      ? ImageUtils.getImageProvider(user.profileImage!)
                      : null,
                  child: user.profileImage == null || user.profileImage!.isEmpty
                      ? Text(
                          "${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}".toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              title: Text(
                "${user.firstName} ${user.lastName}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "@${user.username}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              trailing: Obx(() {
                final isUnblocking = controller.unblockingUsernames.contains(user.username);
                return SizedBox(
                  width: 90,
                  height: 36,
                  child: isUnblocking
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () => _confirmUnblock(context, user.username),
                          child: Text(
                            'Unblock',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                );
              }),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block_outlined,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Blocked Users',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Users you block will appear here. You can unblock them at any time.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const CircleAvatar(radius: 24, backgroundColor: Colors.white),
            title: Container(height: 16, width: 150, color: Colors.white),
            subtitle: Container(height: 12, width: 100, color: Colors.white),
            trailing: Container(
              width: 90,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmUnblock(BuildContext context, String username) {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unblock User?'),
        content: Text('Are you sure you want to unblock @$username? they will be able to see your profile, posts, and message you again.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Get.back(); // Close dialog
              controller.unblockUser(username);
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}
