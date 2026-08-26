import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/models/user_model.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import '../notification/presentation/controllers/notification_controller.dart';
import '../profile/presentation/controllers/profile_controller.dart';
import '../network/presentation/controllers/network_controller.dart';

import 'presentation/terms_consent_dialog.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final isAuthChecked = false.obs;
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
    try {
      final token = await _storage.getAccessToken();
      if (token == null) {
        isLoggedIn.value = false;
        await _navigateUnlessOnActiveCall('/login');
        return;
      }

      // Try to refresh token to see if it's still valid or can be renewed, with 4s timeout
      final canRefresh = await _authService.refreshToken().timeout(
        const Duration(seconds: 4),
        onTimeout: () => false,
      );

      if (canRefresh) {
        final profile = await _storage.getUserProfile();
        userProfile.value = profile;
        isLoggedIn.value = true;
        _fetchInitialData();
        await _navigateUnlessOnActiveCall('/');
      } else {
        isLoggedIn.value = false;
        userProfile.value = null;
        await _storage.clearAll();
        await _navigateUnlessOnActiveCall('/login');
      }
    } catch (e) {
      print('Error checking auth status: $e');
      isLoggedIn.value = false;
      userProfile.value = null;
      await _navigateUnlessOnActiveCall('/login');
    } finally {
      isAuthChecked.value = true;
    }
  }

  /// This runs on every cold start, racing against a killed-app "accept call
  /// from CallKit" flow, which navigates to `/active-call` (see
  /// InitialBinding._consumePendingCallAction / LiveKitService.acceptCall)
  /// once the native side hands the accept back to Dart — which can take a
  /// beat longer than this method's own token-refresh network call.
  /// Without this guard, checkAuthStatus used to win that race and stomp
  /// the call screen (or the screen it was about to become) with
  /// Get.offAllNamed('/') / '/login' — confirmed by production testing as a
  /// visible flash through login/home before the call finally took over,
  /// and in the worst case a call already connected getting kicked back to
  /// home (only endable from the ongoing-call notification afterward).
  Future<void> _navigateUnlessOnActiveCall(String route) async {
    if (Get.currentRoute == '/active-call') return;

    // The app can be launching specifically to answer a call that was
    // already accepted natively (CallKit UI) before Flutter's engine was
    // even up — that acceptance hasn't reached Dart/GetX yet at this exact
    // moment, but the OS/plugin already knows about it. Give that a short
    // window to land on /active-call before falling back to the normal
    // login/home redirect, instead of always taking cold-start's redirect
    // as first-come-first-served.
    try {
      final active = await FlutterCallkitIncoming.activeCalls();
      if (active is List && active.isNotEmpty) {
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (Get.currentRoute == '/active-call') return;
        }
      }
    } catch (_) {}

    Get.offAllNamed(route);
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
    // Show loading dialog manually for better control over dismissal
    Get.dialog(
      PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  "Signing out...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
    );

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
      // Close dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.offAllNamed('/login');
    }
  }

  Future<void> openRegistration() async {
    Get.toNamed('/register');
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final success = await _authService.signInWithSocialProvider('google');
      print('Google Login Success: $success');
      if (success) {
        await _authService.syncWithBackend();
        final profile = await _storage.getUserProfile();
        userProfile.value = profile;
        isLoggedIn.value = true;
        _fetchInitialData();
        Get.offAllNamed('/');
      } else {
        Get.snackbar('Login Failed', 'Google login returned empty result. Check logs for details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Google Login Controller Error: $e');
      Get.snackbar('Google Login Error', e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    isLoading.value = true;
    try {
      final success = await _authService.signInWithSocialProvider('apple');
      print('Apple Login Success: $success');
      if (success) {
        await _authService.syncWithBackend();
        final profile = await _storage.getUserProfile();
        userProfile.value = profile;
        isLoggedIn.value = true;
        _fetchInitialData();
        Get.offAllNamed('/');
      } else {
        Get.snackbar('Login Failed', 'Apple login returned empty result. Check logs for details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Apple Login Controller Error: $e');
      Get.snackbar('Apple Login Error', e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
    } finally {
      isLoading.value = false;
    }
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
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().updateDeviceToken();
    }
    _checkTermsAccepted();
  }

  Future<void> _checkTermsAccepted() async {
    // Wait briefly for ProfileController to finish its refreshProfile
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!Get.isRegistered<ProfileController>()) return;
    final profileCtrl = Get.find<ProfileController>();
    
    // Poll until profile is loaded (max 5s)
    int attempts = 0;
    while (profileCtrl.isLoading.value && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    final termsAccepted = profileCtrl.profileData.value
        ?.userProfile.termsAccepted ?? true;
    
    if (!termsAccepted) {
      Get.dialog(
        const TermsConsentDialog(),
        barrierDismissible: false,
      );
    }
  }
}

