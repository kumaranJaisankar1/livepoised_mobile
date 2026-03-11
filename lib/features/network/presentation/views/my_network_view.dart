import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../chat/data/models/chat_connection.dart';
import '../controllers/network_controller.dart';
import '../../data/models/network_models.dart';
import 'package:livepoised_mobile/core/utils/image_utils.dart';

import 'requests_view.dart';

import '../widgets/network_search_delegate.dart';

class MyNetworkView extends GetView<NetworkController> {
  const MyNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBox(context, theme),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Invitations Section (LinkedIn Style)
            _buildInvitationsRow(theme),
            
            const Divider(height: 1),

            // Tabs Section
            Container(
              color: theme.colorScheme.surface,
              child: Obx(() => TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: 'Allies (${controller.allies.length})'),
                      Tab(text: 'Supports (${controller.supportNetwork.length})'),
                      Tab(text: 'Circle (${controller.extendedCircle.length})'),
                    ],
                  )),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  Obx(() => _buildConnectionsList(controller.allies, 'No allies yet', theme)),
                  Obx(() => _buildConnectionsList(controller.supportNetwork, 'No supporters yet', theme)),
                  Obx(() => _buildConnectionsList(controller.extendedCircle, 'Your circle is empty', theme)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Network',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(),
          InkWell(
            onTap: () => showSearch(
              context: context,
              delegate: NetworkSearchDelegate(),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Search Ally...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildInvitationsRow(ThemeData theme) {
    return Obx(() {
      return InkWell(
        onTap: () => Get.to(() => const RequestsView()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invitations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                children: [
                  if (controller.totalPendingRequests > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.totalPendingRequests}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildConnectionsList(List<Connection> connections, String emptyMessage, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchAllData(),
      child: connections.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: Get.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: theme.disabledColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: connections.length,
              itemBuilder: (context, index) {
                final conn = connections[index];
                final imageProvider = ImageUtils.getImageProvider(conn.imageUrl);
                final isDark = theme.brightness == Brightness.dark;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Optional: Navigate to user profile
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Premium Avatar with subtle ring
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  foregroundImage: imageProvider,
                                  child: Text(
                                    conn.name.isNotEmpty ? conn.name[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      conn.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        // Relationship Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            conn.relationship ?? (conn.isSupport ? 'Supporter' : 'Ally'),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSecondaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Message Action
                              IconButton.filledTonal(
                                onPressed: () {
                                  Get.toNamed('/chat-history', arguments: ChatConnection(
                                    username: conn.username,
                                    firstName: conn.firstName,
                                    lastName: conn.lastName,
                                    profileImage: conn.imageUrl,
                                    connectionType: conn.connectionType,
                                    relationship: conn.relationship,
                                  ));
                                },
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                                tooltip: 'Message',
                                style: IconButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
