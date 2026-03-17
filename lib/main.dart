import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/theme_controller.dart';
import 'routes/app_pages.dart';
import 'features/auth/auth_controller.dart';
import 'features/chat/data/datasource/chat_websocket_service.dart';
import 'features/notification/presentation/controllers/notification_controller.dart';
import 'features/network/presentation/controllers/network_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/services/push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Push Notification Service
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushNotificationService().initialize();

  await GetStorage.init();
  await dotenv.load(fileName: ".env.dev");

  // Global Bindings
  Get.put(GetStorage());
  Get.put(ThemeController());
  Get.put(AuthController());
  final chatWs = Get.put(ChatWebSocketService());
  Get.put(NotificationController());
  Get.put(NetworkController());
  chatWs.connect();

  runApp(const LivePoisedApp());
}

class LivePoisedApp extends StatelessWidget {
  const LivePoisedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Live Poised',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.currentTheme.value,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
