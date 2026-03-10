import 'package:get/get.dart';
import '../../data/models/network_models.dart';
import '../../services/network_service.dart';


class NetworkController extends GetxController {
  final NetworkService _networkService = NetworkService();

  final allies = <Connection>[].obs;
  final supportNetwork = <Connection>[].obs;
  final extendedCircle = <Connection>[].obs;

  final incomingAllyRequests = <NetworkRequest>[].obs;
  final outgoingAllyRequests = <NetworkRequest>[].obs;
  final pendingSupporterRequests = <NetworkRequest>[].obs;

  // Search Results
  final searchResults = <Connection>[].obs;
  final searchQuery = "".obs;
  final isSearching = false.obs;

  final isLoading = false.obs;
  final currentTab = 0.obs;

  int get totalPendingRequests => incomingAllyRequests.length + pendingSupporterRequests.length;

  // Debouncer for search
  Worker? _searchDebouncer;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
    
    // Initialize search debouncer
    _searchDebouncer = debounce(
      searchQuery,
      (query) => _executeSearch(query),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _searchDebouncer?.dispose();
    super.onClose();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchIncomingAllyRequests(),
        fetchOutgoingAllyRequests(),
        fetchPendingSupporterRequests(),
        fetchConnections(),
        fetchPatientAllies(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Search Logic ---

  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      final results = await _networkService.searchUsers(query);
      searchResults.assignAll(results);
    } finally {
      isSearching.value = false;
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
        searchResults.clear();
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
    allies.assignAll(all.where((c) => c.connectionType == 'ALLY').toList());
    supportNetwork.assignAll(all.where((c) => c.connectionType == 'CAREGIVER').toList());
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
