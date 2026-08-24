import 'dart:io';
import 'package:livepoised_mobile/core/network/dio_client.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _dio = DioClient().springBoot;

  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.allNotifications);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.unreadNotifications);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching unread notifications: $e');
      return [];
    }
  }

  Future<bool> markAsRead(int id) async {
    try {
      final response = await _dio.post(ApiEndpoints.markNotificationAsRead(id));
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification $id as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead(List<int> ids) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.markAllNotificationsAsRead,
        data: {'notificationIds': ids},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  Future<bool> registerDeviceToken({required String fcmToken, String? deviceId}) async {
    try {
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web');

      // 1. Sync to FastAPI (used for Chat & Incoming Call FCM pushes)
      try {
        await DioClient().fastAPI.post(
          '/notifications/device-tokens/register',
          data: {
            'fcm_token': fcmToken,
            'device_id': deviceId,
            'platform': platform,
          },
        );
        print('NotificationService: FCM token registered with FastAPI');
      } catch (e) {
        print('NotificationService Warning: FastAPI token sync failed: $e');
      }

      // 2. Sync to Spring Boot
      try {
        await _dio.post(
          ApiEndpoints.registerDeviceToken,
          data: {
            'fcmToken': fcmToken,
            'deviceId': deviceId,
          },
        );
        print('NotificationService: FCM token registered with Spring Boot');
      } catch (e) {
        print('NotificationService Warning: Spring Boot token sync failed: $e');
      }

      return true;
    } catch (e) {
      print('Error registering device token: $e');
      return false;
    }
  }
}
