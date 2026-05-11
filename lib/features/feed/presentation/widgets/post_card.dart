import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import './report_bottom_sheet.dart';
import '../../../auth/auth_controller.dart';
import '../../services/feed_service.dart';
import '../controllers/feed_controller.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onReply,
  });

  String? _extractUrl(String text) {
    final urlRegExp = RegExp(
      r"((https?:|www\.)[^\s]+)",
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final url = _extractUrl(post.content);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    final username = post.authorUserId ?? post.authorName;
                    debugPrint('Navigating to profile: $username');
                    Get.toNamed('/profile/$username');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    backgroundImage: ImageUtils.getImageProvider(post.authorImageUrl),
                    child: post.authorImageUrl == null 
                      ? Text(post.authorName[0]) 
                      : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final username = post.authorUserId ?? post.authorName;
                      debugPrint('Navigating to profile: $username');
                      Get.toNamed('/profile/$username');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName, 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        Text(timeago.format(post.createdAt), style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Ally",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/post-details', arguments: post),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    post.content, 
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (url != null) ...[
                    const SizedBox(height: 12),
                    _CustomLinkPreview(url: url),
                  ],
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: post.tags.map((tag) => Text(
                        '#$tag', 
                        style: TextStyle(color: Theme.of(context).colorScheme.primary)
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likes}',
                  color: post.isLiked ? Colors.red : null,
                  onTap: onLike,
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentsCount}',
                  onTap: onReply,
                ),
                const Spacer(),
                // IconButton(
                //   icon: const Icon(Icons.share_outlined, size: 20),
                //   onPressed: () {},
                // ),
                _buildMenu(context),
              ],
            )
          ],
        ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Obx(() {
      final authController = Get.find<AuthController>();
      final currentUsername = authController.userProfile.value?.username;
      
      final bool isOwner = currentUsername != null && 
          (currentUsername.toLowerCase() == post.authorUserId?.toLowerCase() || 
           currentUsername.toLowerCase() == post.authorName.toLowerCase());

      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (value) async {
        if (value == 'report') {
          Get.bottomSheet(
            ReportBottomSheet(contentId: post.id, isPost: true),
            isScrollControlled: true,
          );
        } else if (value == 'edit') {
          Get.toNamed('/create-post', arguments: {'post': post});
        } else if (value == 'delete') {
          _showDeleteConfirmation();
        }
      },
      itemBuilder: (context) => [
        if (!isOwner)
          const PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Report Post', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        if (isOwner) ...[
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 20),
                SizedBox(width: 8),
                Text('Edit Post'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Post', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ],
    );
    });
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final success = await FeedService().deletePost(post.id);
              if (success) {
                Get.snackbar('Success', 'Post deleted successfully');
                Get.find<FeedController>().fetchPosts(refresh: true);
              } else {
                Get.snackbar('Error', 'Failed to delete post');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}



class _CustomLinkPreview extends StatelessWidget {
  final String url;

  const _CustomLinkPreview({required this.url});

  bool _isVideoLink(String url) {
    return url.contains('youtube.com') || 
           url.contains('youtu.be') || 
           url.contains('vimeo.com') ||
           url.contains('shorts');
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideoLink(url);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnyLinkPreview.builder(
      link: url,
      placeholderWidget: Container(
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      ),
      errorWidget: const SizedBox.shrink(),
      itemBuilder: (context, metadata, imageProvider, _) {
        return InkWell(
          onTap: () async {
            final uri = Uri.tryParse(url);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Blurred background
                      if (imageProvider != null) ...[
                        Image(image: imageProvider, fit: BoxFit.cover),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: (isDark ? Colors.black : Colors.white).withOpacity(0.2),
                          ),
                        ),
                      ] else
                        Container(color: colorScheme.surfaceVariant),

                      // Centered contain image
                      if (imageProvider != null)
                        Image(image: imageProvider, fit: BoxFit.contain),
                      
                      // Centered Play Button for Video
                      if (isVideo)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Title & Description Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: isDark ? colorScheme.surfaceVariant : colorScheme.primaryContainer.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metadata.title ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (metadata.desc != null && metadata.desc!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          metadata.desc!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('PostCard: _ActionButton tapped for: $label');
        onTap?.call();
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

