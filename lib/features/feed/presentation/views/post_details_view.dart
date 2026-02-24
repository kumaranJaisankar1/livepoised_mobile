import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/post.dart';
import '../widgets/post_card.dart';

class PostDetailsView extends StatelessWidget {
  const PostDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final Post post = Get.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('Thread')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                PostCard(
                  post: post,
                  onLike: () {},
                  onReply: () {},
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Discussion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                // Mock replies
                ...List.generate(3, (index) => _ReplyTile(index: index)),
              ],
            ),
          ),
          _ReplyInput(),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  final int index;
  const _ReplyTile({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 16, child: Text('R')),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Replier $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('This is a helpful reply to the medical challenge discussed.'),
                const SizedBox(height: 4),
                const Text('2 hours ago', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ReplyInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add a reply...',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Reply')),
        ],
      ),
    );
  }
}
