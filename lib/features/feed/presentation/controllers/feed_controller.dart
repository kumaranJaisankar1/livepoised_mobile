import 'package:get/get.dart';
import '../../data/models/post.dart';
import '../../data/repository/feed_repository.dart';

class FeedController extends GetxController {
  final FeedRepository _repository = FeedRepository();

  final posts = <Post>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      isLoading.value = true;
    } else if (posts.isNotEmpty) {
      isMoreLoading.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final newPosts = await _repository.getPosts(page: _currentPage);
      if (refresh) {
        posts.assignAll(newPosts);
      } else {
        posts.addAll(newPosts);
      }
      _currentPage++;
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> likePost(String postId) async {
    final success = await _repository.likePost(postId);
    if (success) {
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = posts[index];
        posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
      }
    }
  }
}
