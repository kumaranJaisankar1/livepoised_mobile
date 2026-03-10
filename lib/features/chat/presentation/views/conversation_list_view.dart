import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/image_utils.dart';
import '../controllers/chat_list_controller.dart';
import '../../data/models/chat_connection.dart';

class ConversationListView extends GetView<ChatListController> {
  const ConversationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.connections.isEmpty) {
          return _buildShimmerList(context);
        }

        if (controller.connections.isEmpty) {
          return const Center(
            child: Text('No connections found. Build your ally network to start chatting!'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchConnections(),
          child: ListView.separated(
            itemCount: controller.connections.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final connection = controller.connections[index];
              return _ConnectionTile(connection: connection);
            },
          ),
        );
      }),
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: ListTile(
            leading: const CircleAvatar(radius: 24, backgroundColor: Colors.white),
            title: Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 12,
              width: 100,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  final ChatConnection connection;

  const _ConnectionTile({required this.connection});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: ImageUtils.getImageProvider(connection.profileImage),
        child: connection.profileImage == null || connection.profileImage!.isEmpty
            ? Text(connection.firstName?[0] ?? connection.username[0].toUpperCase())
            : null,
      ),
      title: Text(
        '${connection.firstName ?? ""} ${connection.lastName ?? ""}'.trim().isEmpty
            ? connection.username
            : '${connection.firstName ?? ""} ${connection.lastName ?? ""}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        connection.connectionType?.toUpperCase() == 'CAREGIVER'
            ? (connection.relationship ?? "")
            : '${connection.connectionType ?? ""}  ${connection.relationship ?? ""}',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Get.toNamed('/chat-history', arguments: connection),
    );
  }
}
