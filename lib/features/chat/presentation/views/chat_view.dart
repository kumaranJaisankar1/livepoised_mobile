import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/chat_controller.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/models/chat_message.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final String otherUser = (Get.arguments is String) ? Get.arguments as String : 'Chat';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() {
          final conn = controller.connection.value;
          final String title = conn != null 
              ? '${conn.firstName ?? ""} ${conn.lastName ?? ""}'.trim().isEmpty 
                  ? conn.username 
                  : '${conn.firstName ?? ""} ${conn.lastName ?? ""}'
              : otherUser;

          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: ImageUtils.getImageProvider(conn?.profileImage),
                child: (conn?.profileImage == null || conn!.profileImage!.isEmpty)
                    ? Text(title[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Online', // Simplified for now
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.isLoadingHistory.value
                  ? _buildShimmerChat(context)
                  : controller.messages.isEmpty
                      ? const Center(child: Text('No messages yet. Say hi!'))
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final msg = controller.messages[index];
                            final isMe = msg.senderUsername == controller.currentUsername;

                            return _ChatBubble(message: msg, isMe: isMe);
                          },
                        ),
            ),
          ),
          _MessageInput(
            controller: textController,
            onSend: (text) {
              final String? recipient = controller.otherUsername;
              if (recipient != null) {
                controller.sendMessage(text, recipient);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerChat(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final isMe = index % 3 == 0;
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              width: MediaQuery.of(context).size.width * (0.4 + (index % 4) * 0.1),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                  bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(20),
              ),
              boxShadow: isMe ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ] : [],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${timeago.format(message.timestamp, locale: 'en_short')}${message.isOptimistic ? " • sending..." : ""}',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSend(controller.text.trim());
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
