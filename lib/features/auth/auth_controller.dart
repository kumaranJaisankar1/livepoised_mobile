import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import '../../core/storage/secure_storage_service.dart';

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
    await _authService.logout();
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
