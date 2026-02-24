import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livepoised_mobile/core/storage/secure_storage_service.dart';

class AuthService {
  final Dio _dio = Dio();
  final SecureStorageService _storage = SecureStorageService();

  Future<bool> loginWithCredentials(String username, String password) async {
    try {
      final String url =
          '${dotenv.get('KEYCLOAK_URL')}/realms/${dotenv.get('KEYCLOAK_REALM')}/protocol/openid-connect/token';

      final response = await _dio.post(
        url,
        data: {
          'client_id': dotenv.get('CLIENT_ID'),
          'client_secret': dotenv.get('CLIENT_SECRET'),
          'grant_type': 'password',
          'username': username,
          'password': password,
          'scope': 'openid profile email offline_access',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          idToken: data['id_token'],
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      final message = e.response?.data?['error_description'] ?? e.message;
      print('Direct Login Error: $message');
      throw message;
    } catch (e) {
      print('Direct Login Error: $e');
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final String url =
          '${dotenv.get('KEYCLOAK_URL')}/realms/${dotenv.get('KEYCLOAK_REALM')}/protocol/openid-connect/token';

      final response = await _dio.post(
        url,
        data: {
          'client_id': dotenv.get('CLIENT_ID'),
          'client_secret': dotenv.get('CLIENT_SECRET'),
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          idToken: data['id_token'],
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Token Refresh Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}
