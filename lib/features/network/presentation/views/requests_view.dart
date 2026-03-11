import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/network_controller.dart';
import '../../data/models/network_models.dart';
import 'package:livepoised_mobile/core/utils/image_utils.dart';

class RequestsView extends GetView<NetworkController> {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildReceivedRequestsList(theme),
              _buildSentRequestsList(theme),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildReceivedRequestsList(ThemeData theme) {
    final incomingAllies = controller.incomingAllyRequests;
    final incomingSupporters = controller.pendingSupporterRequests;

    return RefreshIndicator(
      onRefresh: () => controller.fetchAllData(),
      child: (incomingAllies.isEmpty && incomingSupporters.isEmpty)
          ? _buildEmptyState('No incoming requests', theme)
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (incomingAllies.isNotEmpty) ...[
                  _buildSectionHeader('Ally Requests', theme),
                  ...incomingAllies.map((req) => _buildRequestItem(req, theme, true)),
                ],
                if (incomingSupporters.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('Support Network Invitations', theme),
                  ...incomingSupporters.map((req) => _buildRequestItem(req, theme, true)),
                ],
              ],
            ),
    );
  }

  Widget _buildSentRequestsList(ThemeData theme) {
    final outgoing = controller.outgoingAllyRequests;

    return RefreshIndicator(
      onRefresh: () => controller.fetchAllData(),
      child: outgoing.isEmpty
          ? _buildEmptyState('No outgoing requests', theme)
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: outgoing.length,
              itemBuilder: (context, index) {
                final req = outgoing[index];
                return _buildRequestItem(req, theme, false);
              },
            ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: Get.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mail_outline, size: 64, color: theme.disabledColor),
              const SizedBox(height: 16),
              Text(message, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItem(NetworkRequest request, ThemeData theme, bool isIncoming) {
    final imageProvider = ImageUtils.getImageProvider(request.senderImageUrl);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundImage: imageProvider,
          child: Text(
            request.senderUsername[0].toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(request.name),
        subtitle: Text(
          request.type == 'Ally' 
              ? 'Ally Connection' 
              : 'Support: ${request.relationship ?? "Supporter"}'
        ),
        trailing: isIncoming 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.teal),
                    onPressed: () => controller.respondToRequest(request, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    onPressed: () => controller.respondToRequest(request, false),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pending',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
