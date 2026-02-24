import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    surface: AppColors.darkSurface,
    error: AppColors.darkError,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: AppColors.darkTextPrimary,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: AppColors.darkBackground,
  textTheme: AppTextTheme.darkTextTheme,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    foregroundColor: AppColors.darkTextPrimary,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 1,
  ),
);
