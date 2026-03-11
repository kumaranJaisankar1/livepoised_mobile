import 'package:get/get.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_middleware.dart';
import '../features/auth/presentation/views/login_view.dart';
import '../features/feed/presentation/controllers/create_post_controller.dart';
import '../features/feed/presentation/controllers/feed_controller.dart';
import '../features/feed/presentation/views/create_post_view.dart';
import '../features/feed/presentation/views/post_details_view.dart';
import '../features/feed/presentation/controllers/post_details_controller.dart';
import '../features/chat/presentation/controllers/chat_list_controller.dart';
import '../features/chat/presentation/views/conversation_list_view.dart';
import '../features/network/presentation/views/my_network_view.dart';
import '../features/chat/presentation/controllers/chat_controller.dart';
import '../features/chat/presentation/views/chat_view.dart';
import '../features/notification/presentation/controllers/notification_controller.dart';
import '../features/notification/presentation/views/notifications_view.dart';
import '../features/auth/presentation/views/registration_view.dart';
import '../features/auth/presentation/views/social_auth_view.dart';
import '../features/auth/presentation/views/splash_view.dart';
import '../presentation/layouts/main_layout.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/profile/presentation/views/edit_profile_view.dart';
import '../features/profile/presentation/views/settings_view.dart';
import '../features/network/presentation/controllers/network_controller.dart';
import '../features/neuro_wellness/presentation/views/neuro_wellness_lobby_view.dart';
import '../features/neuro_wellness/presentation/controllers/neuro_wellness_controller.dart';
import '../features/neuro_wellness/presentation/views/memory_recall_game_view.dart';

class AppPages {
  static const initial = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashView(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AuthController>()) {
          Get.lazyPut(() => AuthController());
        }
      }),
    ),
    GetPage(
      name: '/register',
      page: () => const RegistrationView(),
    ),
    GetPage(
      name: '/social-auth',
      page: () => const SocialAuthView(),
    ),
    GetPage(
      name: '/',
      page: () => const MainLayout(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MainLayoutController());
        Get.lazyPut(() => FeedController());
        Get.lazyPut(() => ProfileController());
        Get.lazyPut(() => ChatListController());
        Get.lazyPut(() => NeuroWellnessController());
      }),
    ),
    GetPage(
      name: '/create-post',
      page: () => const CreatePostView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CreatePostController());
      }),
    ),
    GetPage(
      name: '/post-details',
      page: () => const PostDetailsView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PostDetailsController());
      }),
    ),
    GetPage(
      name: '/notifications',
      page: () => const NotificationsView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationController());
      }),
    ),
    GetPage(
      name: '/chat',
      page: () => const ConversationListView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatListController());
      }),
    ),
    GetPage(
      name: '/chat-history',
      page: () => const ChatView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatController());
      }),
    ),
    GetPage(
      name: '/edit-profile',
      page: () => const EditProfileView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/neuro-wellness',
      page: () => const NeuroWellnessLobbyView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NeuroWellnessController());
      }),
    ),
    GetPage(
      name: '/neuro-wellness/memory-recall',
      page: () => const MemoryRecallGameView(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
