import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livepoised_mobile/features/auth/auth_controller.dart';
import '../controllers/feed_controller.dart';
import '../widgets/post_card.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
          errorBuilder:
              (context, error, stackTrace) => const Text(
                'Live Poised',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => Get.toNamed('/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchPosts(refresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount:
                controller.posts.length +
                (controller.isMoreLoading.value ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == controller.posts.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final post = controller.posts[index];
              return PostCard(
                post: post,
                onLike: () => controller.likePost(post.id),
                onReply: () => Get.toNamed('/post-details', arguments: post),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-post'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
