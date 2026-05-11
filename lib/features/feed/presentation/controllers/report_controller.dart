import 'package:get/get.dart';
import '../../services/feed_service.dart';

class ReportController extends GetxController {
  final FeedService _feedService = FeedService();
  final isLoading = false.obs;

  Future<bool> submitReport({
    required dynamic contentId,
    required bool isPost,
    required String reason,
    String description = "",
  }) async {
    try {
      isLoading(true);
      
      bool success;
      if (isPost) {
        success = await _feedService.reportPost(
          contentId,
          reason: reason,
          description: description,
        );
      } else {
        success = await _feedService.reportComment(
          contentId,
          reason: reason,
          description: description,
        );
      }

      if (success) {
        Get.snackbar(
          "Report Submitted",
          "Thank you for helping us keep our community safe.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          "Error",
          "Failed to submit report. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred.");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
