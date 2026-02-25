import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import '../../core/storage/secure_storage_service.dart';

import 'package:url_launcher/url_launcher.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  final isLoggedIn = false.obs;
  final isLoading = false.obs;

  final usernameController = ''.obs;
  final passwordController = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _storage.getAccessToken();
    isLoggedIn.value = token != null;
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
        isLoggedIn.value = true;
        Get.offAllNamed('/feed');
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

  Future<void> logout() async {
    isLoading.value = true;
    await _authService.logout();
    isLoggedIn.value = false;
    isLoading.value = false;
    Get.offAllNamed('/login');
  }

  Future<void> openRegistration() async {
    Get.toNamed('/register');
  }

  Future<void> loginWithGoogle() async {
    Get.toNamed('/social-auth', arguments: {'provider': 'google'});
  }

  Future<void> handleSocialAuthCallback(String code) async {
    isLoading.value = true;
    try {
      final success = await _authService.exchangeCodeForToken(code);
      if (success) {
        checkAuthStatus(); // Refresh isLoggedIn observable
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
}
