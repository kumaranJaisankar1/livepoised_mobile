import 'package:get/get.dart';
import '../../data/models/profile_models.dart';
import '../../data/services/profile_service.dart';
import '../../../auth/auth_controller.dart';

class UserProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final AuthController _authController = Get.find<AuthController>();
  
  String get currentUsername => _authController.userProfile.value?.username ?? '';
  
  final String username;
  UserProfileController({required this.username});

  final isLoading = true.obs;
  final profileData = Rxn<ProfileResponse>();
  final userImage = "".obs;
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading(true);
      
      // Fetch profile and image in parallel
      final results = await Future.wait([
        _profileService.getProfileDetailsFastAPI(username),
        _profileService.getUserImage(username),
      ]);
      
      profileData.value = results[0] as ProfileResponse;
      
      // Prioritize the image URL from the profile response (FastAPI)
      final imageUrl = profileData.value?.userProfile.profileImageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        userImage.value = imageUrl;
      } else {
        userImage.value = (results[1] as Map<String, dynamic>)['image'] ?? "";
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile for $username: $e');
    } finally {
      isLoading(false);
    }
  }

  void changeTab(int index) {
    activeTab.value = index;
  }
}
