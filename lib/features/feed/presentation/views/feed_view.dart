import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livepoised_mobile/features/auth/auth_controller.dart';
import 'package:livepoised_mobile/features/notification/presentation/controllers/notification_controller.dart';
import '../controllers/feed_controller.dart';
import '../widgets/post_card.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/create-post'),
          ),
          title: Column(
            children: [
              Image.asset(
                'assets/images/live_poised_font_logo.png',
                height: 45,
                errorBuilder:
                    (context, error, stackTrace) => const Text(
                      'Live Poised',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              Text("FITNESS FOR THE INJURED",style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 10),
              )
            ],
          ),
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) => controller.switchTab(index),
            tabs: const [ 
              Tab(text: 'Latest'),
              Tab(text: 'Trending'),
             
            ],
          ),
          actions: [
            Obx(() {
              final unreadCount = Get.find<NotificationController>().unreadCount.value;
              return Badge.count(
                count: unreadCount,
                alignment: const Alignment(0.3, -0.5),
                isLabelVisible: unreadCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => Get.toNamed('/notifications'),
                ),
              );
            }),
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
    ),
   );
  }
}



