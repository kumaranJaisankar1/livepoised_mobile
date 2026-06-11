import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import 'package:livepoised_mobile/features/auth/auth_controller.dart';
import 'package:livepoised_mobile/features/profile/presentation/controllers/profile_controller.dart';

class TermsConsentDialog extends StatefulWidget {
  const TermsConsentDialog({super.key});

  @override
  State<TermsConsentDialog> createState() => _TermsConsentDialogState();
}

class _TermsConsentDialogState extends State<TermsConsentDialog> {
  bool _accepted = false;
  bool _isSubmitting = false;
  bool _isLoggingOut = false;

  final _authController = Get.find<AuthController>();

  Future<void> _handleDecline() async {
    setState(() {
      _isLoggingOut = true;
    });
    try {
      await _authController.logout();
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _handleAccept() async {
    if (!_accepted || _isSubmitting || _isLoggingOut) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final profileController = Get.find<ProfileController>();
      final success = await profileController.acceptTermsAndConditions();
      if (success) {
        Get.back(); // Close the dialog
      } else {
        Get.snackbar(
          'Error',
          'Failed to accept Terms & Conditions. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _openTermsUrl() async {
    final url = Uri.parse(ApiEndpoints.termsUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open terms URL: ${ApiEndpoints.termsUrl}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not launch browser: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 500, // Maximum width for tablet screens
          constraints: const BoxConstraints(maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Terms & EULA Agreement",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Please review and accept to continue using LivePoised",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Zero-Tolerance Policy Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          border: Border(
                            left: BorderSide(
                              color: Colors.redAccent.shade400,
                              width: 4,
                            ),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent.shade400,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Zero-Tolerance Policy",
                                    style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "There is absolute zero tolerance for objectionable content or abusive users. Hateful, harassing, offensive, or obscene behaviors will result in immediate ban and content deletion within 24 hours.",
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "To ensure LivePoised remains a safe, positive, and supportive space for recovery and fitness, all members must agree to our End User License Agreement (EULA) terms:",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // EULA Bullets Card
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildBulletItem(
                              context,
                              "Supportive Conduct",
                              "Treat all members with empathy, respect, and kindness.",
                            ),
                            const Divider(height: 24),
                            _buildBulletItem(
                              context,
                              "No Objectionable Content",
                              "Do not upload or share obscene, offensive, hateful, or discriminatory materials.",
                            ),
                            const Divider(height: 24),
                            _buildBulletItem(
                              context,
                              "24-Hour Moderation SLA",
                              "Flagged content is reviewed and violating items/users are removed within 24 hours.",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // External Link Center Button
                      Center(
                        child: TextButton.icon(
                          onPressed: _openTermsUrl,
                          icon: Icon(
                            Icons.open_in_new_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          label: Text(
                            "Read Full Terms & Guidelines",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              // Footer
              Container(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Checkbox row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _accepted,
                            onChanged: _isSubmitting || _isLoggingOut
                                ? null
                                : (val) {
                                    setState(() {
                                      _accepted = val ?? false;
                                    });
                                  },
                            activeColor: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSubmitting || _isLoggingOut
                                ? null
                                : () {
                                    setState(() {
                                      _accepted = !_accepted;
                                    });
                                  },
                            child: const Text(
                              "I agree to the End User License Agreement (EULA) and understand that objectionable content or abusive behavior will lead to my immediate ban.",
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Tablet: side-by-side, Mobile: stacked
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useSideBySide = constraints.maxWidth > 350;
                        final declineButton = OutlinedButton(
                          onPressed: _isSubmitting ? null : _handleDecline,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoggingOut
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Decline & Logout"),
                        );

                        final acceptButton = ElevatedButton(
                          onPressed: !_accepted || _isSubmitting || _isLoggingOut
                              ? null
                              : _handleAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("I Agree & Continue"),
                        );

                        if (useSideBySide) {
                          return Row(
                            children: [
                              Expanded(child: declineButton),
                              const SizedBox(width: 12),
                              Expanded(child: acceptButton),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              acceptButton,
                              const SizedBox(height: 8),
                              declineButton,
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletItem(BuildContext context, String title, String description) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
