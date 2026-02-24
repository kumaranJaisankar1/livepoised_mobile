import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_controller.dart';

class CreatePostView extends StatelessWidget {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final feedController = Get.find<FeedController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                // Success logic
                Get.back();
                Get.snackbar('Success', 'Post created successfully');
              }
            },
            child: const Text(
              'Post',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(child: Text('U')),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.tag_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.location_on_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
