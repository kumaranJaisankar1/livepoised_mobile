import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:livepoised_mobile/features/auth/auth_controller.dart';
import '../../data/models/profile_models.dart';
import '../../data/services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  // Observables
  final isLoading = true.obs;
  final profileData = Rxn<ProfileResponse>();
  final userImage = "".obs;
  final connectionsCount = 0.obs;
  final activeTab = 0.obs;
  
  // Tab-specific data
  final forumContributions = <ForumContribution>[].obs;
  final chatSessions = <ChatSession>[].obs;
  final isContributionsLoading = false.obs;
  final isSessionsLoading = false.obs;
  final isSaving = false.obs;

  // Form Field Observables
  // Tab 1: Personal
  final usernameC = "".obs;
  final firstNameC = "".obs;
  final middleNameC = "".obs;
  final lastNameC = "".obs;
  final prefixC = "".obs;
  final suffixC = "".obs;
  final genderC = "".obs;
  final dobC = Rxn<DateTime>();

  // Tab 2: Contact
  final emailC = "".obs;
  final mobileNumberC = "".obs;
  final phone1C = "".obs;
  final phone2C = "".obs;
  final addressLine1C = "".obs;
  final addressLine2C = "".obs;
  final cityC = "".obs;
  final stateC = "".obs;
  final countryC = "".obs;
  final postalCodeC = "".obs;

  // Tab 3: Health
  final aboutMeC = "".obs;
  final injuryTypeC = "".obs;
  final injuryDetailsC = "".obs;
  final yearsSinceInjuryC = 0.obs;
  final yearsSinceRecoveryC = 0.obs;
  final personalStoryC = "".obs;
  final conditionDetailsC = "".obs;
  final stageOfRecoveryC = "".obs;
  final recoveryMilestonesC = <RecoveryMilestone>[].obs;
  final achievementsC = <Achievement>[].obs;

  // Tab 4: Support (Logic will be added in view, but tracking selected for now)
  
  // Tab 5: Mentorship
  final offerSupportC = false.obs;
  final mentorshipGoalsC = "".obs;
  final fitnessLevelC = "".obs;
  final availabilityHoursC = 0.obs;

  final _box = Get.find<GetStorage>();
  static const _profileCacheKey = 'profile_cache';
  static const _userImageCacheKey = 'user_image_cache';
  static const _connectionsCountCacheKey = 'connections_count_cache';

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    refreshProfile();
  }

  void _loadFromCache() {
    try {
      final cachedProfile = _box.read(_profileCacheKey);
      if (cachedProfile != null) {
        profileData.value = ProfileResponse.fromJson(cachedProfile);
      }
      userImage.value = _box.read(_userImageCacheKey) ?? "";
      connectionsCount.value = _box.read(_connectionsCountCacheKey) ?? 0;
    } catch (e) {
      print("Error loading profile from cache: $e");
    }
  }

  Future<void> refreshProfile() async {
    final username = _authController.userProfile.value?.username;
    if (username == null) {
      isLoading(false);
      return;
    }
    
    try {
      isLoading(true);
      
      // Fetch core profile, image, and connections in parallel
      final results = await Future.wait([
        _profileService.getProfileDetails(username),
        _profileService.getUserImage(username),
        _profileService.getConnectionsCount(),
      ]);
      
      final profile = results[0] as ProfileResponse;
      final image = (results[1] as Map<String, dynamic>)['image'] ?? "";
      final count = results[2] as int;

      profileData.value = profile;
      userImage.value = image;
      connectionsCount.value = count;

      // Persistence
      _box.write(_profileCacheKey, profile.toJson());
      _box.write(_userImageCacheKey, image);
      _box.write(_connectionsCountCacheKey, count);
      
      // Load initial tab data
      loadTabData(activeTab.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading(false);
    }
  }

  void clearData() {
    isLoading(false);
    profileData.value = null;
    userImage.value = "";
    connectionsCount.value = 0;
    forumContributions.clear();
    chatSessions.clear();
    activeTab.value = 0;
    
    _box.remove(_profileCacheKey);
    _box.remove(_userImageCacheKey);
    _box.remove(_connectionsCountCacheKey);
  }

  void loadTabData(int index) {
    activeTab.value = index;
    final userId = profileData.value?.userProfile.userId.toString();
    if (userId == null) return;

    if (index == 2 && forumContributions.isEmpty) {
      _fetchContributions(userId);
    } else if (index == 3 && chatSessions.isEmpty) {
      _fetchChatSessions(userId);
    }
  }

  Future<void> _fetchContributions(String userId) async {
    isContributionsLoading(true);
    try {
      final data = await _profileService.getForumContributions(userId);
      forumContributions.assignAll(data);
    } finally {
      isContributionsLoading(false);
    }
  }

  Future<void> _fetchChatSessions(String userId) async {
    isSessionsLoading(true);
    try {
      final data = await _profileService.getChatSessions(userId);
      chatSessions.assignAll(data);
    } finally {
      isSessionsLoading(false);
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compresses image to 70% quality for faster upload
      );
      
      if (image != null) {
        await uploadAvatar(File(image.path));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> uploadAvatar(File file) async {
    final username = _authController.userProfile.value?.username;
    if (username == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      Get.showOverlay(
        asyncFunction: () async {
          final result = await _profileService.uploadImage(
            username,
            file,
            onProgress: (sent, total) {
              print("Upload Progress: ${(sent / total * 100).toStringAsFixed(0)}%");
            },
          );

          // Refetch the uploaded image to ensure synchronous backend update
          try {
            final imageData = await _profileService.getUserImage(username);
            final newImage = imageData['image'] ?? result['image'] ?? "";
            userImage.value = newImage;
            _box.write(_userImageCacheKey, newImage);
            Get.snackbar('Success', 'Profile image updated');
          } catch (e) {
            print('Failed to refetch image: $e');
            // Graceful fallback to the upload response
            userImage.value = result['image'] ?? "";
            _box.write(_userImageCacheKey, userImage.value);
            Get.snackbar('Success', 'Profile image uploaded');
          }
        },
        loadingWidget: Center(child: CircularProgressIndicator()),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    }
  }

  void initEditForm() {
    final profile = profileData.value;
    if (profile == null) return;

    final user = profile.userProfile;
    final details = profile.personalDetails;
    final addr = profile.address;

    // Tab 1
    usernameC.value = user.username;
    firstNameC.value = user.firstName;
    middleNameC.value = user.middleName ?? "";
    lastNameC.value = user.lastName;
    prefixC.value = user.prefix ?? "";
    suffixC.value = user.suffix ?? "";
    genderC.value = user.gender;
    if (user.dateOfBirth.isNotEmpty) {
      try {
        dobC.value = DateTime.parse(user.dateOfBirth);
      } catch (_) {}
    }

    // Tab 2
    emailC.value = user.email;
    mobileNumberC.value = user.mobileNumber ?? "";
    phone1C.value = user.phone1 ?? "";
    phone2C.value = user.phone2 ?? "";
    addressLine1C.value = addr?.addressLine1 ?? "";
    addressLine2C.value = addr?.addressLine2 ?? "";
    cityC.value = addr?.city ?? "";
    stateC.value = addr?.state ?? "";
    countryC.value = addr?.country ?? "";
    postalCodeC.value = addr?.postalCode ?? "";

    // Tab 3
    aboutMeC.value = user.aboutMe ?? "";
    injuryTypeC.value = details?.injuryType ?? "";
    injuryDetailsC.value = details?.injuryDetails ?? "";
    yearsSinceInjuryC.value = details?.yearsSinceInjury ?? 0;
    yearsSinceRecoveryC.value = details?.yearsSinceRecovery ?? 0;
    personalStoryC.value = details?.personalStory ?? "";
    conditionDetailsC.value = details?.conditionDetails ?? "";
    stageOfRecoveryC.value = details?.stageOfRecovery ?? "";
    recoveryMilestonesC.assignAll(details?.recoveryMilestones ?? []);
    achievementsC.assignAll(details?.achievements ?? []);

    // Tab 5
    offerSupportC.value = details?.offerSupport ?? false;
    mentorshipGoalsC.value = details?.mentorshipGoals ?? "";
    fitnessLevelC.value = details?.fitnessLevel ?? "";
    availabilityHoursC.value = details?.availabilityHoursPerWeek ?? 0;
  }

  Future<void> saveProfile() async {
    final username = _authController.userProfile.value?.username;
    if (username == null) return;

    try {
      isSaving(true);
      final payload = {
        "userProfile": {
          "mobileNumber": mobileNumberC.value,
          "phone1": phone1C.value,
          "phone2": phone2C.value,
          "firstName": firstNameC.value,
          "middleName": middleNameC.value,
          "lastName": lastNameC.value,
          "suffix": suffixC.value,
          "prefix": prefixC.value,
          "gender": genderC.value,
          "dateOfBirth": dobC.value?.toIso8601String().split('T')[0] ?? "",
          "aboutMe": aboutMeC.value,
        },
        "address": {
          "addressLine1": addressLine1C.value,
          "addressLine2": addressLine2C.value,
          "city": cityC.value,
          "state": stateC.value,
          "country": countryC.value,
          "postalCode": postalCodeC.value,
        },
        "personalDetails": {
          "injuryType": injuryTypeC.value,
          "injuryDetails": injuryDetailsC.value,
          "yearsSinceInjury": yearsSinceInjuryC.value.toString(),
          "yearsSinceRecovery": yearsSinceRecoveryC.value.toString(),
          "recoveryMilestones": recoveryMilestonesC.map((m) => {
            if (m.id != 0) "id": m.id,
            "title": m.title,
            "date": m.date,
            "type": m.type,
          }).toList(),
          "achievements": achievementsC.map((a) => {
            if (a.id != 0) "id": a.id,
            "title": a.title,
            "month": a.month,
          }).toList(),
          "personalStory": personalStoryC.value,
          "conditionDetails": conditionDetailsC.value,
          "stageOfRecovery": stageOfRecoveryC.value,
          "mentorshipGoals": mentorshipGoalsC.value,
          "fitnessLevel": fitnessLevelC.value,
          "availabilityHoursPerWeek": availabilityHoursC.value,
          "offerSupport": offerSupportC.value,
        }
      };

      final result = await _profileService.updateProfile(username, payload);
      
      // Handle various success response formats (String, Map with status, or raw object)
      bool isSuccess = false;
      if (result is Map) {
        if (result.containsKey('status')) {
          isSuccess = result['status'] == 'success';
        } else {
          // If it's a map but doesn't have a status, it's likely the updated profile object itself
          isSuccess = true;
        }
      } else {
        // If result is not a map, assume success if no Dio error was thrown
        isSuccess = true;
      }

      if (isSuccess) {
        Get.snackbar('Success', 'Profile updated successfully');
        await refreshProfile();
        // Return true to indicate success
        Get.back();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e');
    } finally {
      isSaving(false);
    }
  }
}
