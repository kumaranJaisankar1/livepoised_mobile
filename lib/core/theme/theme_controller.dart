import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  Rx<ThemeMode> currentTheme = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    final isDarkMode = _box.read(_key);
    if (isDarkMode == null) {
      currentTheme.value = ThemeMode.system;
    } else {
      currentTheme.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void toggleTheme() {
    if (currentTheme.value == ThemeMode.dark) {
      currentTheme.value = ThemeMode.light;
      _box.write(_key, false);
    } else {
      currentTheme.value = ThemeMode.dark;
      _box.write(_key, true);
    }
    Get.changeThemeMode(currentTheme.value);
  }

  void setSystemTheme() {
    currentTheme.value = ThemeMode.system;
    _box.remove(_key);
    Get.changeThemeMode(ThemeMode.system);
  }

  bool get isDarkMode => currentTheme.value == ThemeMode.dark;
}
