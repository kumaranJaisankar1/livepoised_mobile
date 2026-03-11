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
    final themeValue = _box.read(_key);
    if (themeValue == null) {
      currentTheme.value = ThemeMode.system;
    } else if (themeValue == 'dark') {
      currentTheme.value = ThemeMode.dark;
    } else if (themeValue == 'light') {
      currentTheme.value = ThemeMode.light;
    } else {
      // Legacy support for boolean version
      currentTheme.value = themeValue == true ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void setThemeMode(ThemeMode mode) {
    currentTheme.value = mode;
    if (mode == ThemeMode.system) {
      _box.remove(_key);
    } else {
      _box.write(_key, mode == ThemeMode.dark ? 'dark' : 'light');
    }
    Get.changeThemeMode(mode);
  }

  bool get isDarkMode => currentTheme.value == ThemeMode.dark || 
      (currentTheme.value == ThemeMode.system && Get.isPlatformDarkMode);
}
