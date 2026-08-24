import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safe_text/safe_text.dart';

import 'core/bindings/initial_binding.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/call/presentation/widgets/floating_call_overlay.dart';
import 'features/notification/presentation/controllers/notification_controller.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';

Future<void> _initFirebaseAndPNS() async {
  try {
    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint('Main: Options init failed: $e, trying default init...');
        await Firebase.initializeApp();
      }
    }
    debugPrint('Main: Firebase initialized. Apps: ${Firebase.apps.length}');
  } catch (e) {
    debugPrint('Main: Firebase.initializeApp failed: $e');
    return;
  }

  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Main: FirebaseMessaging handler error: $e');
  }

  try {
    await PushNotificationService().initialize();
  } catch (e) {
    debugPrint('Main: PushNotificationService initialize error: $e');
  }

  // Register FCM token with Spring Boot after Firebase is ready
  try {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().updateDeviceToken();
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Storage and env init first — PushNotificationService.initialize()
  // (called from _initFirebaseAndPNS below) syncs the FCM token to the
  // backend immediately after fetching it, which needs dotenv loaded to
  // resolve the backend URL. Loading it after caused a NotInitializedError
  // on every cold start, silently breaking FCM token registration.
  try {
    await SafeTextFilter.init(language: Language.english);
  } catch (_) {}
  await GetStorage.init();
  await dotenv.load(fileName: '.env.dev');

  // 2. Initialize Firebase & PNS
  await _initFirebaseAndPNS();

  runApp(const LivePoisedApp());
}

class LivePoisedApp extends StatelessWidget {
  const LivePoisedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Live Poised',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.currentTheme.value,
          initialBinding: InitialBinding(),
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          defaultTransition: Transition.fade,
          builder: (context, child) {
            return Stack(
              children: [if (child != null) child, const FloatingCallOverlay()],
            );
          },
        );
      },
    );
  }
}
