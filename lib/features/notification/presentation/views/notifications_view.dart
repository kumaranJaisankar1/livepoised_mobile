import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/notification_controller.dart';
import '../../data/models/notification_model.dart';

class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: () => controller.markAllAsRead(),
                child: const Text('Mark all as read'),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return _buildShimmerNotifications(context);
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No notifications yet!'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _NotificationTile(notification: notification);
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerNotifications(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.separated(
      itemCount: 12,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: ListTile(
            leading: const CircleAvatar(radius: 20, backgroundColor: Colors.white),
            title: Container(
              height: 16,
              width: double.infinity,
              margin: const EdgeInsets.only(right: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 12,
              width: 80,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends GetView<NotificationController> {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _NotificationIcon(type: notification.notificationType),
      title: Text(
        notification.message,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        timeago.format(notification.createdAt),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      tileColor: notification.read 
          ? null 
          : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      onTap: () => controller.handleNotificationTap(notification),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final NotificationType type;

  const _NotificationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.chatMessage:
        icon = Icons.chat_bubble_outline;
        color = Colors.blue;
        break;
      case NotificationType.allyRequest:
      case NotificationType.allyRequestAccepted:
        icon = Icons.person_add_outlined;
        color = Colors.green;
        break;
      case NotificationType.forumPostReply:
        icon = Icons.reply_outlined;
        color = Colors.orange;
        break;
      case NotificationType.commentLike:
      case NotificationType.postLike:
        icon = Icons.favorite_border;
        color = Colors.red;
        break;
      case NotificationType.mentorRequest:
        icon = Icons.school_outlined;
        color = Colors.purple;
        break;
      case NotificationType.goalMilestone:
        icon = Icons.trending_up;
        color = Colors.teal;
        break;
      default:
        icon = Icons.notifications_outlined;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
