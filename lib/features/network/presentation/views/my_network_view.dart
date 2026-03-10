import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/network_controller.dart';
import '../../data/models/network_models.dart';
import 'package:livepoised_mobile/core/utils/image_utils.dart';

import 'requests_view.dart';

class MyNetworkView extends GetView<NetworkController> {
  const MyNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Network'),
          actions: [
            Obx(() => Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () => Get.to(() => const RequestsView()),
                    ),
                    if (controller.totalPendingRequests > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${controller.totalPendingRequests}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                )),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Obx(() => TabBar(
                  tabs: [
                    Tab(text: 'Allies (${controller.allies.length})'),
                    Tab(text: 'Supports (${controller.supportNetwork.length})'),
                    Tab(text: 'Circle (${controller.extendedCircle.length})'),
                  ],
                )),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Search Ally to add...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.isSearching.value
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Search Results (Optional Overlay or List)
              if (controller.searchResults.isNotEmpty)
                _buildSearchResults(theme),

              // Manage Requests Banner (If pending)
              if (controller.totalPendingRequests > 0 && controller.searchResults.isEmpty)
                _buildRequestsBanner(theme),

              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildConnectionsList(controller.allies, 'No allies yet', theme),
                    _buildConnectionsList(controller.supportNetwork, 'No supporters yet', theme),
                    _buildConnectionsList(controller.extendedCircle, 'Your circle is empty', theme),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = controller.searchResults[index];
          final imageProvider = ImageUtils.getImageProvider(user.imageUrl);
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundImage: imageProvider,
                child: Text(user.name[0]),
              ),
              title: Text(user.name),
              subtitle: Text('@${user.username}'),
              trailing: ElevatedButton(
                onPressed: () => _showRequestDialog(context, user),
                child: const Text('Add'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsBanner(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You have ${controller.totalPendingRequests} new connection requests.',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Get.to(() => const RequestsView()),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog(BuildContext context, Connection user) {
    String selectedRelationship = "SPOUSE";
    final List<String> relationships = ["SPOUSE", "PARENT", "SIBLING", "FRIEND", "CAREGIVER", "PROFESSIONAL", "OTHER"];

    Get.dialog(
      AlertDialog(
        title: Text("Add ${user.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select your relationship:"),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRelationship,
              items: relationships.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) {
                if (val != null) selectedRelationship = val;
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              controller.sendRequest(user.username, selectedRelationship, true);
              Get.back();
            },
            child: const Text("Send Request"),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(List<Connection> connections, String emptyMessage, ThemeData theme) {
    if (connections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(emptyMessage, style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: connections.length,
      itemBuilder: (context, index) {
        final conn = connections[index];
        final imageProvider = ImageUtils.getImageProvider(conn.imageUrl);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundImage: imageProvider,
              child: Text(
                conn.name[0].toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(conn.name),
            subtitle: Text(conn.relationship ?? (conn.isSupport ? 'Supporter' : 'Ally')),
            trailing: ElevatedButton(
              onPressed: () {
                // Navigate to chat with this user
                Get.toNamed('/chat-history', arguments: {'username': conn.username, 'name': conn.name});
              },
              child: const Text('Message'),
            ),
          ),
        );
      },
    );
  }
}
