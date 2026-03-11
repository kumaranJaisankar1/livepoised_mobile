import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../notification/presentation/controllers/notification_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final notificationController = Get.find<NotificationController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          Obx(() => _buildSettingTile(
                context,
                title: 'Theme Mode',
                subtitle: _getThemeModeString(themeController.currentTheme.value),
                icon: Icons.palette_outlined,
                onTap: () => _showThemeSelectionDialog(context, themeController),
              )),
          const Divider(),
          _buildSectionHeader(context, 'Notifications'),
          Obx(() => SwitchListTile(
                secondary: Icon(
                  notificationController.isNotificationsEnabled.value
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive updates and message alerts'),
                value: notificationController.isNotificationsEnabled.value,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) => notificationController.toggleNotifications(val),
              )),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          _buildSettingTile(
            context,
            title: 'App Version',
            subtitle: '1.0.4 (Build 1843)',
            icon: Icons.info_outline,
          ),
          _buildSettingTile(
            context,
            title: 'Terms of Service',
            icon: Icons.description_outlined,
          ),
          _buildSettingTile(
            context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'LIVE POISED - FITNESS FOR THE INJURED',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context,
      {required String title,
      String? subtitle,
      required IconData icon,
      VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))
          : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
      onTap: onTap,
    );
  }

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  void _showThemeSelectionDialog(BuildContext context, ThemeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, controller, ThemeMode.system, 'System Default', Icons.brightness_auto),
            _buildThemeOption(context, controller, ThemeMode.light, 'Light Mode', Icons.light_mode_outlined),
            _buildThemeOption(context, controller, ThemeMode.dark, 'Dark Mode', Icons.dark_mode_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeController controller, ThemeMode mode, String label, IconData icon) {
    return Obx(() => RadioListTile<ThemeMode>(
          title: Text(label),
          secondary: Icon(icon),
          value: mode,
          groupValue: controller.currentTheme.value,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (newMode) {
            if (newMode != null) {
              controller.setThemeMode(newMode);
              Get.back();
            }
          },
        ));
  }
}
