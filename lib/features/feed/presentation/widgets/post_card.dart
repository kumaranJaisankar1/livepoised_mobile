import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: post.authorAvatar != null ? NetworkImage(post.authorAvatar!) : null,
                child: post.authorAvatar == null ? Text(post.authorName[0]) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(timeago.format(post.createdAt), style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
              if (post.medicalCategory != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.medicalCategory!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          if (post.hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: post.hashtags.map((tag) => Text('#$tag', style: TextStyle(color: Theme.of(context).colorScheme.primary))).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likesCount}',
                color: post.isLiked ? Colors.red : null,
                onTap: onLike,
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.repliesCount}',
                onTap: onReply,
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
