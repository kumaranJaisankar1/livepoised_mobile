import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:livepoised_mobile/features/feed/data/models/comment.dart';
import 'package:livepoised_mobile/features/feed/data/models/post.dart';
import '../../data/models/post_detail_response.dart';
import '../../services/feed_service.dart';
import '../../../auth/auth_controller.dart';
import 'feed_controller.dart';

class PostDetailsController extends GetxController {
  final FeedService _feedService = FeedService();
  final AuthController _authController = Get.find<AuthController>();
  final FeedController _feedController = Get.find<FeedController>();

  final post = Rxn<Post>();
  final comments = <Comment>[].obs;
  final isLoading = false.obs;
  final isLiking = false.obs;
  final replyToComment = Rxn<Comment>();

  void setReplyTo(Comment comment) {
    replyToComment.value = comment;
  }

  void clearReply() {
    replyToComment.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Post) {
      post.value = _updatePostLikeStatus(args);
      fetchPostDetails(args.id.toString());
    }
  }

  Future<void> fetchPostDetails(dynamic postId) async {
    final String id = postId.toString();
    isLoading.value = true;
    try {
      final response = await _feedService.getPostDetails(id);
      if (response != null) {
        post.value = _updatePostLikeStatus(response.post);
        comments.assignAll(response.commentsTree.map((c) => _updateCommentLikeStatus(c)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments');
    } finally {
      isLoading.value = false;
    }
  }

  Post _updatePostLikeStatus(Post post) {
    final username = _authController.userProfile.value?.username;
    if (username == null) return post;
    final isLikedByMe = post.likedBy.contains(username);
    return post.copyWith(isLiked: isLikedByMe);
  }

  Comment _updateCommentLikeStatus(Comment comment) {
    final username = _authController.userProfile.value?.username;
    bool isLikedByMe = comment.isLiked;
    if (username != null) {
      isLikedByMe = comment.likedBy.contains(username);
    }
    
    final updatedChildren = comment.children.map((child) => _updateCommentLikeStatus(child)).toList();
    
    return comment.copyWith(
      isLiked: isLikedByMe,
      children: updatedChildren,
    );
  }

  Future<void> likePost() async {
    debugPrint('PostDetailsController: likePost() called');
    if (post.value == null || isLiking.value) {
      debugPrint('PostDetailsController: likePost early return (post null or already liking)');
      return;
    }

    final currentPost = post.value!;
    // Optimistic update
    post.value = currentPost.copyWith(
      isLiked: !currentPost.isLiked,
      likes: currentPost.isLiked ? currentPost.likes - 1 : currentPost.likes + 1,
    );

    isLiking.value = true;
    try {
      final success = await _feedService.likePost(currentPost.id);
      if (success) {
        // Trigger background refetch for FeedView
        _feedController.fetchPosts(refresh: true);
      } else {
        // Revert on failure
        post.value = currentPost;
        Get.snackbar('Error', 'Failed to like post');
      }
    } catch (e) {
      post.value = currentPost;
      Get.snackbar('Error', 'Failed to like post');
    } finally {
      isLiking.value = false;
    }
  }

  Future<void> addComment(String text, {String? parentId}) async {
    if (post.value == null || text.trim().isEmpty) return;

    isLoading.value = true;
    try {
      final success = await _feedService.createComment(post.value!.id, text, parentId: parentId);
      if (success) {
        // Refresh comments
        clearReply();
        await fetchPostDetails(post.value!.id);
        
        // Trigger background refetch for FeedView
        _feedController.fetchPosts(refresh: true);
        
        Get.snackbar('Success', 'Comment posted');
      } else {
        Get.snackbar('Error', 'Failed to post comment');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to post comment');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeComment(dynamic commentId) async {
    try {
      final success = await _feedService.likeComment(commentId);
      if (success) {
        // Refresh to show updated likes (simplified, could be manual update)
        await fetchPostDetails(post.value!.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to like comment');
    }
  }
}
