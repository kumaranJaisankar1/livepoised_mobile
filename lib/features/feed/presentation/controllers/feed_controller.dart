import 'package:get/get.dart';
import '../../data/models/post.dart';
import '../../data/repository/feed_repository.dart';
import '../../services/feed_service.dart';
import '../../../auth/auth_controller.dart';

class FeedController extends GetxController {
  final FeedRepository _repository = FeedRepository();
  final FeedService _feedService = FeedService();
  final AuthController _authController = Get.find<AuthController>();

  final posts = <Post>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final selectedTab = 0.obs; // 0 for Trending, 1 for Latest

  Post _updatePostLikeStatus(Post post) {
    final username = _authController.userProfile.value?.username;
    if (username == null) return post;
    final isLikedByMe = post.likedBy.contains(username);
    return post.copyWith(isLiked: isLikedByMe);
  }

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      isLoading.value = true;
    } else if (posts.isNotEmpty) {
      isMoreLoading.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      List<Post> newPosts;
      if (selectedTab.value == 0) {
        newPosts = await _feedService.getLatestPosts();
      } else {
        newPosts = await _feedService.getTrendingPosts();
      }

      if (refresh) {
        posts.assignAll(newPosts.map((p) => _updatePostLikeStatus(p)).toList());
      } else {
        // FastAPI returns whole list for now based on docs, 
        // but adding for consistency if pagination is added later
        posts.assignAll(newPosts.map((p) => _updatePostLikeStatus(p)).toList()); 
      }
    } catch (e) {
      print('Fetch Posts Error: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void switchTab(int index) {
    if (selectedTab.value != index) {
      selectedTab.value = index;
      fetchPosts(refresh: true);
    }
  }

  Future<void> likePost(dynamic postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final originalPost = posts[index];
    
    // Optimistic update
    posts[index] = originalPost.copyWith(
      isLiked: !originalPost.isLiked,
      likes: originalPost.isLiked ? originalPost.likes - 1 : originalPost.likes + 1,
    );

    try {
      final success = await _feedService.likePost(postId);
      if (success) {
        // Refresh to ensure server state is captured (e.g. likedBy list)
        await fetchPosts();
      } else {
        // Revert on failure
        posts[index] = originalPost;
      }
    } catch (e) {
      posts[index] = originalPost;
      print('Like Post Error: $e');
    }
  }

  Future<void> deletePost(dynamic postId) async {
    try {
      final success = await _feedService.deletePost(postId);
      if (success) {
        posts.removeWhere((p) => p.id == postId);
        Get.snackbar('Success', 'Post deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete post');
      }
    } catch (e) {
      print('Delete Post Error: $e');
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }
}
