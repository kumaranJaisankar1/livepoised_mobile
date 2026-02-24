import 'package:get/get.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_middleware.dart';
import '../features/auth/presentation/views/login_view.dart';
import '../features/feed/presentation/controllers/feed_controller.dart';
import '../features/feed/presentation/views/create_post_view.dart';
import '../features/feed/presentation/views/post_details_view.dart';
import '../features/chat/presentation/controllers/chat_controller.dart';
import '../features/chat/presentation/views/chat_view.dart';
import '../features/notification/presentation/views/notifications_view.dart';
import '../presentation/layouts/main_layout.dart';

class AppPages {
  static const initial = '/login';

  static final routes = [
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
      name: '/',
      page: () => const MainLayout(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MainLayoutController());
        Get.lazyPut(() => FeedController());
      }),
    ),
    GetPage(
      name: '/create-post',
      page: () => const CreatePostView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/post-details',
      page: () => const PostDetailsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/notifications',
      page: () => const NotificationsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/chat',
      page: () => const ChatView(),
      middlewares: [AuthMiddleware()],
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatController());
      }),
    ),
  ];
}
