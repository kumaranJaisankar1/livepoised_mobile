import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:get/get.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/models/post.dart';
import 'package:timeago/timeago.dart' as timeago;

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

    return InkWell(
      onTap: () => Get.toNamed('/post-details', arguments: post),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: ImageUtils.getImageProvider(post.authorImageUrl),
                  child: post.authorImageUrl == null 
                    ? Text(post.authorName[0]) 
                    : null,
                ),
                const SizedBox(width: 12),
                Expanded(
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
            const SizedBox(height: 16),
            Row(
              children: [
                _ActionButton(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likes}',
                  color: post.isLiked ? Colors.red : null,
                  onTap: (e) {
                    onLike();
                  },
                ),
                const SizedBox(width: 24),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.commentsCount}',
                  onTap: (e) {
                    onReply();
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {},
                )
              ],
            )
          ],
        ),
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

    return AnyLinkPreview.builder(
      link: url,
      placeholderWidget: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: const SizedBox.shrink(),
      itemBuilder: (context, metadata, imageProvider, _) {
        return ClipRRect(
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
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ] else
                      Container(color: Colors.black87),

                    // Centered contain image
                    if (imageProvider != null)
                      Image(image: imageProvider, fit: BoxFit.contain),
                    
                    // Centered Play Button for Video
                    if (isVideo)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
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
                color: const Color(0xFF032D28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metadata.title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (metadata.desc != null && metadata.desc!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        metadata.desc!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontFamily: 'Inter',
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
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function(TapDownDetails)? onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTap,
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

