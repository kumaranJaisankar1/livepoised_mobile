import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared post-game dialog for every Neuro Wellness game — replaces each
/// game's own plain `Get.defaultDialog` call with one consistent, on-brand
/// design. "Back to Lobby" always navigates explicitly to `/neuro-wellness`
/// (Get.offNamed) rather than relying on `Get.back(closeOverlays: true)`'s
/// pop-counting — that was landing on the Feed tab instead of the lobby
/// whenever the popped-route count didn't line up with the actual stack
/// depth. An explicit named destination has no such ambiguity.
class GameResultDialog extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String message;
  final VoidCallback onTryAgain;

  const GameResultDialog({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.message,
    required this.onTryAgain,
  });

  static Future<void> show({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String message,
    required VoidCallback onTryAgain,
  }) {
    return Get.dialog(
      GameResultDialog(
        icon: icon,
        accentColor: accentColor,
        title: title,
        message: message,
        onTryAgain: onTryAgain,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accentColor, accentColor.withOpacity(0.6)],
                ),
                boxShadow: [
                  BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.65)),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  onTryAgain();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Try Again", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.offNamed('/neuro-wellness'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Back to Lobby",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
