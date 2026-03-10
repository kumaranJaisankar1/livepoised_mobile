import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livepoised_mobile/features/chat/presentation/views/conversation_list_view.dart';
import 'package:livepoised_mobile/features/network/presentation/views/my_network_view.dart';
import 'package:livepoised_mobile/features/feed/presentation/views/feed_view.dart';
import 'package:livepoised_mobile/features/profile/presentation/views/profile_view.dart';

import 'package:livepoised_mobile/features/network/presentation/controllers/network_controller.dart';

class MainLayoutController extends GetxController {
  var currentIndex = 0.obs;

  final pages = [
    const FeedView(),
    const ConversationListView(),
    const SizedBox.shrink(), // Placeholder for Create Post (which opens a new route)
    const MyNetworkView(),
    const ProfileView(),
  ];

  void changeIndex(int index) {
    if (index == 2) {
      Get.toNamed('/create-post');
    } else {
      currentIndex.value = index;
    }
  }
}

class MainLayout extends GetView<MainLayoutController> {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () {
          final networkController = Get.find<NetworkController>();
          final requestCount = networkController.totalPendingRequests;

          return BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Feed',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.wechat_outlined),
                activeIcon: Icon(Icons.wechat),
                label: 'Chat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                label: 'Create',
              ),
              BottomNavigationBarItem(
                icon: Badge.count(
                  count: requestCount,
                  isLabelVisible: requestCount > 0,
                  child: const Icon(Icons.people_outline_outlined),
                ),
                activeIcon: Badge.count(
                  count: requestCount,
                  isLabelVisible: requestCount > 0,
                  child: const Icon(Icons.people_rounded),
                ),
                label: 'My Network',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
