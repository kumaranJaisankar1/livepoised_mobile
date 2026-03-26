import 'package:get/get.dart';
import '../../../auth/auth_controller.dart';
import '../../data/models/network_models.dart';
import '../../services/network_service.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import 'package:get_storage/get_storage.dart';


class NetworkController extends GetxController {
  final NetworkService _networkService = NetworkService();

  final allies = <Connection>[].obs;
  final supportNetwork = <Connection>[].obs;
  final extendedCircle = <Connection>[].obs;

  final incomingAllyRequests = <NetworkRequest>[].obs;
  final outgoingAllyRequests = <NetworkRequest>[].obs;
  final pendingSupporterRequests = <NetworkRequest>[].obs;

  // Search Results
  final matchmakingResults = <AllyMatch>[].obs;
  final searchQuery = "".obs;
  final isSearching = false.obs;
  final matchmakingError = "".obs;

  // Matchmaking Filters
  final selectedCondition = "".obs;
  final selectedCountry = "".obs;
  final selectedLanguages = <String>[].obs;
  final minExperienceYears = 0.obs;
  final selectedLiveExperienceTags = <String>[].obs;
  final offerSupport = false.obs;

  final isLoading = false.obs;
  final currentTab = 0.obs;

  int get totalPendingRequests => incomingAllyRequests.length + pendingSupporterRequests.length;

  // Debouncer for search
  Worker? _searchDebouncer;

  final _box = Get.find<GetStorage>();
  static const _alliesCacheKey = 'allies_cache';
  static const _supportNetworkCacheKey = 'support_network_cache';
  static const _incomingRequestsCacheKey = 'incoming_requests_cache';
  static const _pendingSupporterRequestsCacheKey = 'pending_supporter_requests_cache';

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    fetchAllData();
    
    // Initialize search debouncer
    _searchDebouncer = debounce(
      searchQuery,
      (query) => executeMatchmakingSearch(query),
      time: const Duration(milliseconds: 500),
    );
  }

  void _loadFromCache() {
    try {
      final cachedAllies = _box.read(_alliesCacheKey);
      if (cachedAllies != null) {
        allies.assignAll((cachedAllies as List).map((e) => Connection.fromJson(e)).toList());
      }
      final cachedSupport = _box.read(_supportNetworkCacheKey);
      if (cachedSupport != null) {
        supportNetwork.assignAll((cachedSupport as List).map((e) => Connection.fromJson(e)).toList());
      }
      final cachedIncoming = _box.read(_incomingRequestsCacheKey);
      if (cachedIncoming != null) {
        incomingAllyRequests.assignAll((cachedIncoming as List).map((e) => NetworkRequest.fromJson(e)).toList());
      }
      final cachedPendingSupporter = _box.read(_pendingSupporterRequestsCacheKey);
      if (cachedPendingSupporter != null) {
        pendingSupporterRequests.assignAll((cachedPendingSupporter as List).map((e) => NetworkRequest.fromJson(e)).toList());
      }
    } catch (e) {
      print("Error loading network data from cache: $e");
    }
  }

  void clearData() {
    allies.clear();
    supportNetwork.clear();
    extendedCircle.clear();
    incomingAllyRequests.clear();
    outgoingAllyRequests.clear();
    pendingSupporterRequests.clear();
    matchmakingResults.clear();
    searchQuery.value = "";
    matchmakingError.value = "";
    
    _box.remove(_alliesCacheKey);
    _box.remove(_supportNetworkCacheKey);
    _box.remove(_incomingRequestsCacheKey);
    _box.remove(_pendingSupporterRequestsCacheKey);
  }

  @override
  void onClose() {
    _searchDebouncer?.dispose();
    super.onClose();
  }

  Future<void> fetchAllData() async {
    if (allies.isEmpty && incomingAllyRequests.isEmpty) isLoading.value = true;
    try {
      await Future.wait([
        fetchIncomingAllyRequests(),
        fetchOutgoingAllyRequests(),
        fetchPendingSupporterRequests(),
        fetchConnections(),
        fetchPatientAllies(),
      ]);
      
      // Update Cache
      _box.write(_alliesCacheKey, allies.map((e) => e.toJson()).toList());
      _box.write(_supportNetworkCacheKey, supportNetwork.map((e) => e.toJson()).toList());
      _box.write(_incomingRequestsCacheKey, incomingAllyRequests.map((e) => e.toJson()).toList());
      _box.write(_pendingSupporterRequestsCacheKey, pendingSupporterRequests.map((e) => e.toJson()).toList());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Search Logic ---

  Future<void> updateSearchQuery(String query) {
    searchQuery.value = query;
    return Future.value();
  }

  // Temporary tombstone to prevent crashes from stale GetX workers after Hot Reload
  void _executeSearch(String query) => executeMatchmakingSearch(query);

  Future<void> executeMatchmakingSearch(String query) async {
    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();
    
    final user = authController.userProfile.value;
    final profile = profileController.profileData.value;
    
    if (user == null) return;

    isSearching.value = true;
    matchmakingError.value = ""; // Reset error
    try {
      final request = FindAllyRequest(
        userId: profile?.userProfile.userId ?? user.sub,
        username: user.username ?? 'Unknown',
        query: query,
        condition: selectedCondition.value.isNotEmpty 
            ? selectedCondition.value 
            : profile?.personalDetails?.conditionDetails ?? '',
        preferredCountry: selectedCountry.value,
        preferredLanguages: selectedLanguages.toList(),
        minExperienceYears: minExperienceYears.value,
        liveExperienceTags: selectedLiveExperienceTags.toList(),
        offerSupport: offerSupport.value ? true : null, // Only send if true
        topK: 5,
      );

      final matches = await _networkService.findMentors(request);
      matchmakingResults.assignAll(matches);
    } catch (e) {
      if (e is String) {
        matchmakingError.value = e;
      } else {
        matchmakingError.value = "An error occurred during matchmaking";
      }
      matchmakingResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> sendAllyRequest(String mentorUsername) async {
    isLoading.value = true;
    try {
      final success = await _networkService.sendAllyConnectionRequest(mentorUsername);
      if (success) {
        Get.snackbar('Success', 'Ally request sent to $mentorUsername');
        fetchAllData();
      } else {
        Get.snackbar('Error', 'Failed to send ally request');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendRequest(String username, String relationship, bool isAlly) async {
    isLoading.value = true;
    try {
      final success = await _networkService.sendConnectionRequest(username, relationship, isAlly);
      if (success) {
        Get.snackbar('Success', 'Request sent to $username');
        // Clear search or query if needed
        searchQuery.value = "";
        matchmakingResults.clear();
        fetchAllData(); // Refresh to show in outgoing if supported
      } else {
        Get.snackbar('Error', 'Failed to send request');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Core Data Fetching ---

  Future<void> fetchIncomingAllyRequests() async {
    incomingAllyRequests.assignAll(await _networkService.getIncomingAllyRequests());
  }

  Future<void> fetchOutgoingAllyRequests() async {
    outgoingAllyRequests.assignAll(await _networkService.getOutgoingAllyRequests());
  }

  Future<void> fetchPendingSupporterRequests() async {
    pendingSupporterRequests.assignAll(await _networkService.getPendingSupporterRequests());
  }

  Future<void> fetchConnections() async {
    final all = await _networkService.getConnections();
    allies.assignAll(all.where((c) => c.connectionType?.toUpperCase() == 'ALLY').toList());
    supportNetwork.assignAll(all.where((c) => c.connectionType?.toUpperCase() == 'CAREGIVER').toList());
  }

  Future<void> fetchPatientAllies() async {
    extendedCircle.assignAll(await _networkService.getPatientAllies());
  }

  Future<void> respondToRequest(NetworkRequest request, bool accept) async {
    bool success = false;
    if (request.type == 'Ally') {
      success = await _networkService.respondToAllyRequest(request.id, accept);
    } else {
      success = await _networkService.respondToSupporterRequest(request.id, accept);
    }

    if (success) {
      Get.snackbar('Success', 'Request ${accept ? 'accepted' : 'rejected'}');
      fetchAllData();
    } else {
      Get.snackbar('Error', 'Failed to respond to request');
    }
  }

  void switchTab(int index) {
    currentTab.value = index;
  }
}
