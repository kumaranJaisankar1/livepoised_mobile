import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/models/user_model.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import '../notification/presentation/controllers/notification_controller.dart';
import '../profile/presentation/controllers/profile_controller.dart';
import '../network/presentation/controllers/network_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final userProfile = Rxn<UserModel>();

  final rememberMe = false.obs;
  final savedUsername = ''.obs;
  final savedPassword = ''.obs;
  final isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
    loadRememberedCredentials();
  }

  Future<void> loadRememberedCredentials() async {
    rememberMe.value = await _storage.getRememberMe();
    if (rememberMe.value) {
      final creds = await _storage.getRememberedCredentials();
      savedUsername.value = creds['username'] ?? '';
      savedPassword.value = creds['password'] ?? '';
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      isLoggedIn.value = false;
      Get.offAllNamed('/login');
      return;
    }

    // Try to refresh token to see if it's still valid or can be renewed
    final canRefresh = await _authService.refreshToken();
    if (canRefresh) {
      final profile = await _storage.getUserProfile();
      userProfile.value = profile;
      isLoggedIn.value = true;
      _fetchInitialData();
      Get.offAllNamed('/');
    } else {
      isLoggedIn.value = false;
      userProfile.value = null;
      await _storage.clearAll();
      Get.offAllNamed('/login');
    }
  }

  Future<void> loginInApp(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter both username and password');
      return;
    }

    isLoading.value = true;
    try {
      final success = await _authService.loginWithCredentials(username, password);
      if (success) {
        // Save or clear credentials based on Remember Me
        await _storage.setRememberMe(rememberMe.value);
        if (rememberMe.value) {
          await _storage.saveRememberedCredentials(username, password);
        } else {
          await _storage.clearRememberedCredentials();
        }

        // Sync with backend after successful Keycloak login
        await _authService.syncWithBackend();
        final profile = await _storage.getUserProfile();
        userProfile.value = profile;
        isLoggedIn.value = true;
        _fetchInitialData();
        Get.offAllNamed('/');
      }
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithBrowser() async {
    isLoading.value = true;
    try {
      final success = await _authService.signInWithBrowser();
      if (success) {
        // Sync with backend after successful Keycloak login
        await _authService.syncWithBackend();
        final profile = await _storage.getUserProfile();
        userProfile.value = profile;
        isLoggedIn.value = true;
        _fetchInitialData();
        Get.offAllNamed('/');
      } else {
        Get.snackbar('Login Cancelled', 'Browser login was not completed.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      // Clear all data caches in controllers
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().clearData();
      }
      if (Get.isRegistered<NetworkController>()) {
        Get.find<NetworkController>().clearData();
      }
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().clearData();
      }

      await _authService.logout();
      
      // Clear secure storage (tokens, profile)
      await _storage.clearAll();
      
      // Clear GetStorage persistence
      final box = Get.find<GetStorage>();
      final keys = box.getKeys();
      for (var key in keys) {
        if (key != 'isDarkMode') { // Keep theme preference
           box.remove(key);
        }
      }

      userProfile.value = null;
      isLoggedIn.value = false;
    } catch (e) {
      print("Logout error: $e");
    } finally {
      isLoading.value = false;
      Get.offAllNamed('/login');
    }
  }

  Future<void> openRegistration() async {
    Get.toNamed('/register');
  }

  Future<void> loginWithGoogle() async {
    // Standard OIDC flow often handles IDP selection via kc_idp_hint
    // But loginWithBrowser already provides the standard Keycloak login page
    // where users can select Google if configured. 
    // To go DIRECTLY to Google, we'd use getSocialLoginUrl with a webview,
    // but the recommended flow in the guide is browser-based PKCE.
    loginWithBrowser();
  }

  Future<void> handleSocialAuthCallback(String code) async {
    isLoading.value = true;
    try {
      final success = await _authService.exchangeCodeForToken(code);
      if (success) {
        await _authService.syncWithBackend();
        final profile = await _storage.getUserProfile();
        userProfile.value = profile;
        checkAuthStatus(); // Refresh isLoggedIn observable
        _fetchInitialData();
        Get.offAllNamed('/');
      } else {
        Get.snackbar('Error', 'Social login failed during token exchange');
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _fetchInitialData() {
    if (Get.isRegistered<NetworkController>()) {
      Get.find<NetworkController>().fetchAllData();
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().refreshProfile();
    }
  }
}

