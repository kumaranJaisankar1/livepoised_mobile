import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../data/models/profile_models.dart';
import '../../data/services/profile_service.dart';

class CaregiverController extends GetxController {
  final ProfileService _profileService = ProfileService();
  
  var searchResults = <LinkedUserDTO>[].obs;
  var pendingRequests = <PendingCaregiverRequest>[].obs;
  var allies = <Caregiver>[].obs;
  var suggestions = <LinkedUserDTO>[].obs;
  
  var searchQuery = "".obs;
  var isSearching = false.obs;
  var isLoading = false.obs;
  
  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    _syncWithProfile();
    fetchInitialData();
    _debounceWorker = debounce(searchQuery, (_) => search(searchQuery.value), time: 500.milliseconds);
  }

  void _syncWithProfile() {
    try {
      final profileController = Get.find<ProfileController>();
      if (profileController.profileData.value != null) {
        allies.value = profileController.profileData.value!.userProfile.caregivers;
      }
    } catch (e) {
      print('ProfileController not found yet: $e');
    }
  }

  void fetchInitialData() async {
    try {
      isLoading(true);
      final results = await Future.wait([
        _profileService.getPendingRequests(),
        _profileService.getPatientAllies(),
        _profileService.getSuggestedConnections(),
      ]);
      pendingRequests.value = results[0] as List<PendingCaregiverRequest>;
      
      // Merge allies from API with profile data if needed, or just prioritize API
      final apiAllies = results[1] as List<Caregiver>;
      if (apiAllies.isNotEmpty) {
        allies.value = apiAllies;
      } else {
        _syncWithProfile(); // Fallback to profile data
      }
      
      suggestions.value = results[2] as List<LinkedUserDTO>;
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    super.onClose();
  }

  void search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    try {
      isSearching(true);
      searchResults.value = await _profileService.searchCaregivers(query);
    } finally {
      isSearching(false);
    }
  }

  Future<void> sendRequest(String username, String relationship) async {
    try {
      isLoading(true);
      final message = await _profileService.sendCaregiverRequest(username, relationship);
      Get.snackbar('Request Sent', message);
      fetchInitialData(); // Refresh lists
    } finally {
      isLoading(false);
    }
  }

  void respondToReq(int linkId, bool accept) async {
    try {
      isLoading(true);
      final success = await _profileService.respondToRequest(linkId, accept);
      if (success) {
        Get.snackbar('Success', accept ? 'Request accepted' : 'Request rejected');
        fetchInitialData();
      } else {
        Get.snackbar('Error', 'Failed to respond to request');
      }
    } finally {
      isLoading(false);
    }
  }
}
