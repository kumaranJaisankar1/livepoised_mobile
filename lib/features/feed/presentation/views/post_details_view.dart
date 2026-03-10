import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/comment.dart';
import '../widgets/post_card.dart';
import '../controllers/post_details_controller.dart';

class PostDetailsView extends GetView<PostDetailsController> {
  const PostDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Details')),
      body: Obx(() {
        if (controller.isLoading.value && controller.post.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final post = controller.post.value;
        if (post == null) {
          return const Center(child: Text('Post not found'));
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchPostDetails(post.id),
                child: ListView(
                  children: [
                    PostCard(
                      post: post,
                      onLike: controller.likePost,
                      onReply: () {
                        // Focus reply input for top-level comment
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Comments (${post.commentsCount})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (controller.comments.isEmpty && !controller.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No comments yet. Be the first to reply!')),
                      )
                    else
                      ...controller.comments.map((comment) => _CommentItem(comment: comment)),
                  ],
                ),
              ),
            ),
            _ReplyInput(onSend: (text, {parentId}) => controller.addComment(text, parentId: parentId)),
          ],
        );
      }),
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Comment comment;
  final int depth;

  const _CommentItem({required this.comment, this.depth = 0});

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailsController>();
    final theme = Theme.of(context);
    final hasChildren = widget.comment.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 16.0 + (widget.depth > 0 ? 32.0 : 0) + (widget.depth > 1 ? (widget.depth - 1) * 20.0 : 0),
            right: 16.0,
            top: 12.0,
            bottom: 4.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: widget.depth == 0 ? 18 : 14,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: widget.comment.authorImageUrl != null && widget.comment.authorImageUrl!.isNotEmpty
                    ? NetworkImage(widget.comment.authorImageUrl!)
                    : null,
                child: widget.comment.authorImageUrl == null || widget.comment.authorImageUrl!.isEmpty
                    ? Text(
                        widget.comment.authorName.isNotEmpty ? widget.comment.authorName[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: widget.depth == 0 ? 12 : 10),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.3, color: theme.colorScheme.onSurface),
                        children: [
                          TextSpan(
                            text: widget.comment.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(widget.comment.text),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (widget.comment.createdAt != null)
                          Text(
                            timeago.format(widget.comment.createdAt!, locale: 'en_short'),
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                          ),
                        if (widget.comment.likes > 0) ...[
                          const SizedBox(width: 16),
                          Text(
                            '${widget.comment.likes} ${widget.comment.likes == 1 ? 'like' : 'likes'}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => controller.setReplyTo(widget.comment),
                            child: Text(
                              'Reply',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.hintColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (hasChildren && !_showReplies)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _showReplies = true),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 1,
                                color: theme.hintColor.withOpacity(0.3),
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Text(
                                'View ${widget.comment.children.length} ${widget.comment.children.length == 1 ? 'reply' : 'replies'}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasChildren && _showReplies)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _showReplies = false),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 1,
                                color: theme.hintColor.withOpacity(0.3),
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Text(
                                'Hide replies',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => controller.likeComment(widget.comment.id.toString()),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    widget.comment.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: widget.comment.isLiked ? Colors.red : theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasChildren && _showReplies)
          ...widget.comment.children.map((child) => _CommentItem(comment: child, depth: widget.depth + 1)),
      ],
    );
  }
}

class _ReplyInput extends StatefulWidget {
  final Function(String, {String? parentId}) onSend;

  const _ReplyInput({required this.onSend});

  @override
  State<_ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends State<_ReplyInput> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final controller = Get.find<PostDetailsController>();

  @override
  void initState() {
    super.initState();
    // Listen for reply state changes to focus input
    ever(controller.replyToComment, (comment) {
      if (comment != null) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final replyComment = controller.replyToComment.value;
      final isReply = replyComment != null;

      return Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReply)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Row(
                  children: [
                    Text(
                      'Replying to ${replyComment.authorName}',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.clearReply(),
                      child: Icon(Icons.close, size: 14, color: theme.hintColor),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: isReply ? 'reply to ${replyComment.authorName}...' : 'Join the conversation..',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.6), fontSize: 14),
                      ),
                      maxLines: 5,
                      minLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _textController.text.trim().isEmpty ? theme.hintColor.withOpacity(0.4) : theme.colorScheme.primary,
                    size: 24,
                  ),
                  onPressed: () {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      widget.onSend(text, parentId: replyComment?.id.toString());
                      _textController.clear();
                      _focusNode.unfocus();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

