import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/utils/image_utils.dart';
import '../controllers/chat_list_controller.dart';
import '../../data/models/inbox_item.dart';

class ConversationListView extends GetView<ChatListController> {
  const ConversationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Obx(() => controller.isSearchActive.value
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.toggleSearch(),
              )
            : Icon(Icons.message_outlined)),
        title: Obx(() => controller.isSearchActive.value
            ? TextField(
                controller: controller.searchTextController,
                onChanged: (value) => controller.updateSearch(value),
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search conversations...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Messages')),
        actions: [
          Obx(() => controller.isSearchActive.value
              ? (controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.clearSearch(),
                    )
                  : const SizedBox.shrink())
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => controller.toggleSearch(),
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.inboxItems.isEmpty) {
          return _buildShimmerList(context);
        }

        final items = controller.filteredInboxItems;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                controller.searchQuery.value.isEmpty
                    ? 'No conversations found. Build your ally network to start chatting!'
                    : 'No conversations match your search.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchInbox(),
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final inboxItem = items[index];
              return _ConnectionTile(item: inboxItem);
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
  final InboxItem item;

  const _ConnectionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = '${item.otherUserFirstName ?? ""} ${item.otherUserLastName ?? ""}'.trim().isEmpty
        ? item.otherUsername
        : '${item.otherUserFirstName ?? ""} ${item.otherUserLastName ?? ""}';

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: ImageUtils.getImageProvider(item.otherUserImageUrl),
        child: item.otherUserImageUrl == null || item.otherUserImageUrl!.isEmpty
            ? Text(title[0].toUpperCase())
            : null,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        item.lastMessage ?? 'Started a conversation',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        timeago.format(item.timestamp, locale: 'en_short'),
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      onTap: () => Get.toNamed('/chat-history', arguments: item),
    );
  }
}
