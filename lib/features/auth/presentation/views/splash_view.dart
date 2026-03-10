import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth_controller.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController is already initialized in main.dart, 
    // and its onInit calls checkAuthStatus.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.live_help,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
