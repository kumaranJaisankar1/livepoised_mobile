import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/chat_controller.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/models/chat_message.dart';
import '../../../call/data/livekit_service.dart';

String chatTimeStamp(DateTime timestamp) {
  return DateFormat('hh:mm a').format(timestamp.toLocal());
}

String formatChatDateHeader(DateTime timestamp) {
  final date = timestamp.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final msgDate = DateTime(date.year, date.month, date.day);

  if (msgDate == today) {
    return 'Today';
  } else if (msgDate == yesterday) {
    return 'Yesterday';
  } else if (date.year == now.year) {
    return DateFormat('MMM d').format(date);
  } else {
    return DateFormat('MMM d, yyyy').format(date);
  }
}

bool isDifferentDay(DateTime d1, DateTime d2) {
  final local1 = d1.toLocal();
  final local2 = d2.toLocal();
  return local1.year != local2.year || local1.month != local2.month || local1.day != local2.day;
}

bool isCallMessage(String? content) {
  if (content == null || content.isEmpty) return false;
  final lower = content.trim().toLowerCase();
  return lower.contains('missed call') ||
      lower.contains('call declined') ||
      lower.contains('voice call') ||
      lower.contains('video call') ||
      lower.contains('call started') ||
      lower.contains('call ended') ||
      lower.startsWith('[call') ||
      lower.startsWith('[missed');
}

String formatCallMessageText(String content) {
  if (content.isEmpty) return '';
  final cleaned = content.replaceAll(RegExp(r'^[\[📞\s]+|[\]\s]+$'), '').trim();
  final lower = cleaned.toLowerCase();
  if (lower == 'missed call') return 'Missed voice call';
  if (lower == 'call declined') return 'Call declined';
  if (lower == 'voice call' || lower == 'call started') return 'Voice call';
  if (lower == 'video call') return 'Video call';
  if (lower.startsWith('call ended') || lower.contains('call ended')) return cleaned;
  return cleaned;
}

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() {
          final item = controller.inboxItem.value;
          final String fallbackTitle = controller.otherUsername ?? 'Chat';
          final String title = item != null
              ? '${item.otherUserFirstName ?? ""} ${item.otherUserLastName ?? ""}'.trim().isEmpty
                  ? item.otherUsername
                  : '${item.otherUserFirstName ?? ""} ${item.otherUserLastName ?? ""}'
              : fallbackTitle;

          final isTyping = controller.isOtherUserTyping.value;

          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: ImageUtils.getImageProvider(item?.otherUserImageUrl),
                child: (item?.otherUserImageUrl == null || item?.otherUserImageUrl?.isEmpty == true)
                    ? Text(title.isNotEmpty ? title[0].toUpperCase() : 'C')
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
                      isTyping ? 'Typing...' : 'Connected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isTyping ? FontWeight.bold : FontWeight.normal,
                        color: isTyping
                            ? Colors.tealAccent
                            : Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            tooltip: 'Voice Call',
            onPressed: () {
              final recipient = controller.otherUsername;
              if (recipient != null && recipient.isNotEmpty) {
                final item = controller.inboxItem.value;
                final name = item != null
                    ? '${item.otherUserFirstName ?? ""} ${item.otherUserLastName ?? ""}'.trim()
                    : recipient;

                Get.find<LiveKitService>().startCall(
                  recipient,
                  withVideo: false,
                  targetImage: item?.otherUserImageUrl,
                  targetName: name.isNotEmpty ? name : recipient,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Video Call',
            onPressed: () {
              final recipient = controller.otherUsername;
              if (recipient != null && recipient.isNotEmpty) {
                final item = controller.inboxItem.value;
                final name = item != null
                    ? '${item.otherUserFirstName ?? ""} ${item.otherUserLastName ?? ""}'.trim()
                    : recipient;

                Get.find<LiveKitService>().startCall(
                  recipient,
                  withVideo: true,
                  targetImage: item?.otherUserImageUrl,
                  targetName: name.isNotEmpty ? name : recipient,
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
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
                          controller: controller.scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: controller.messages.length + (controller.isLoadingMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.messages.length && controller.isLoadingMore.value) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            }

                            final msg = controller.messages[index];
                            if (msg.content.trim().isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final isMe = msg.senderUsername == controller.currentUsername;

                            bool showDateHeader = false;
                            if (index == controller.messages.length - 1) {
                              showDateHeader = true;
                            } else {
                              final prevMsgInTime = controller.messages[index + 1];
                              showDateHeader = isDifferentDay(msg.timestamp, prevMsgInTime.timestamp);
                            }

                            final recipient = controller.otherUsername;
                            final item = controller.inboxItem.value;
                            final name = item != null
                                ? '${item.otherUserFirstName ?? ""} ${item.otherUserLastName ?? ""}'.trim()
                                : (recipient ?? '');

                            void handleCallBack() {
                              if (recipient != null && recipient.isNotEmpty) {
                                final isVideo = msg.content.toLowerCase().contains('video');
                                Get.find<LiveKitService>().startCall(
                                  recipient,
                                  withVideo: isVideo,
                                  targetImage: item?.otherUserImageUrl,
                                  targetName: name.isNotEmpty ? name : recipient,
                                );
                              }
                            }

                            return Column(
                              children: [
                                if (showDateHeader)
                                  _TimelineSeparator(dateText: formatChatDateHeader(msg.timestamp)),
                                _ChatBubble(
                                  message: msg,
                                  isMe: isMe,
                                  otherUserImageUrl: controller.inboxItem.value?.otherUserImageUrl,
                                  otherUserInitial: (controller.inboxItem.value?.otherUserFirstName ??
                                      controller.inboxItem.value?.otherUsername ??
                                      "C")[0].toUpperCase(),
                                  onCallBack: handleCallBack,
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ),
          _MessageInput(
            controller: textController,
            onChanged: (text) => controller.onTextChanged(text),
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

class _TimelineSeparator extends StatelessWidget {
  final String dateText;

  const _TimelineSeparator({required this.dateText});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: dividerColor, thickness: 1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Divider(color: dividerColor, thickness: 1)),
        ],
      ),
    );
  }
}

class _CallMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onCallBack;

  const _CallMessageBubble({
    required this.message,
    required this.isMe,
    this.onCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final text = formatCallMessageText(message.content);
    final lower = message.content.toLowerCase();
    final isMissed = lower.contains('missed');
    final isDeclined = lower.contains('declined');
    final isVideo = lower.contains('video');
    final isCallEnded = lower.contains('call ended');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData iconData = Icons.phone;
    if (isMissed) {
      iconData = Icons.phone_missed;
    } else if (isDeclined || isCallEnded) {
      iconData = Icons.phone_disabled;
    } else if (isVideo) {
      iconData = Icons.videocam;
    }

    final String timeStr = chatTimeStamp(message.timestamp);

    return InkWell(
      onTap: onCallBack,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? (isDark ? Colors.teal[700] : Colors.teal[600])
              : (isDark ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
            bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: !isMe
              ? Border.all(color: isDark ? (Colors.grey[800] ?? Colors.grey) : (Colors.grey[200] ?? Colors.grey))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMe
                    ? Colors.white.withOpacity(0.2)
                    : (isMissed || isDeclined)
                        ? Colors.red.withOpacity(0.1)
                        : Colors.teal.withOpacity(0.1),
              ),
              child: Icon(
                iconData,
                size: 18,
                color: isMe
                    ? Colors.white
                    : (isMissed || isDeclined)
                        ? Colors.red
                        : Colors.teal,
              ),
            ),
            const SizedBox(width: 10),

            // Call details
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isMe
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.grey[900]),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    onCallBack != null
                        ? 'Tap to call back'
                        : (isVideo ? 'Video call' : 'Voice call'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? Colors.teal[100]
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Timestamp
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.teal[100]
                    : (isDark ? Colors.grey[400] : Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String? otherUserImageUrl;
  final String otherUserInitial;
  final VoidCallback? onCallBack;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    this.otherUserImageUrl,
    required this.otherUserInitial,
    this.onCallBack,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCall = isCallMessage(message.content);
    final String timeStr = chatTimeStamp(message.timestamp);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: ImageUtils.getImageProvider(otherUserImageUrl),
              child: (otherUserImageUrl?.isEmpty ?? true)
                  ? Text(otherUserInitial, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: isCall
                ? _CallMessageBubble(
                    message: message,
                    isMe: isMe,
                    onCallBack: onCallBack,
                  )
                : Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? (isDark ? Colors.teal[700] : Colors.teal[600])
                          : (isDark ? Colors.grey[850] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                        bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(18),
                      ),
                      border: !isMe
                          ? Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)
                          : null,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: isMe
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.grey[900]),
                          ),
                        ),
                        Text(
                          '$timeStr${message.isOptimistic ? " • sending..." : ""}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? Colors.teal[100]
                                : (isDark ? Colors.grey[400] : Colors.grey[500]),
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
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function(String) onSend;

  const _MessageInput({
    required this.controller,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, size: 20),
                color: Colors.white,
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onSend(controller.text.trim());
                    controller.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
