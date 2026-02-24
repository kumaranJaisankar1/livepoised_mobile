import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livepoised_mobile/features/ally/presentation/views/ally_view.dart';
import 'package:livepoised_mobile/features/feed/presentation/views/feed_view.dart';
import 'package:livepoised_mobile/features/profile/presentation/views/profile_view.dart';
import 'package:livepoised_mobile/features/search/presentation/views/search_view.dart';

class MainLayoutController extends GetxController {
  var currentIndex = 0.obs;

  final pages = [
    const FeedView(),
    const SearchView(),
    const SizedBox.shrink(), // Placeholder for Create Post (which opens a new route)
    const AllyView(),
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
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.6),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Feed',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Ally',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
