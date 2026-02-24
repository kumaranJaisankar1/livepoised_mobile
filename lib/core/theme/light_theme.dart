import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    surface: AppColors.lightSurface,
    error: AppColors.lightError,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.lightTextPrimary,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.lightBackground,
  textTheme: AppTextTheme.lightTextTheme,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightTextPrimary,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: AppColors.lightSurface,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.black.withOpacity(0.05),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.lightDivider,
    thickness: 1,
  ),
);
