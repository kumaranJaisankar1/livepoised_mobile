import 'dart:convert';
import 'package:crypto/crypto.dart';
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

  String getSocialLoginUrl(String provider) {
    // Standard OIDC Authorization Flow for Social Login
    const verifier = 'livepoised_social_auth_verifier_consistent';
    
    // Generate S256 Challenge
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    final challenge = base64Url.encode(digest.bytes).replaceAll('=', '');
    
    return '${dotenv.get('KEYCLOAK_URL')}/realms/${dotenv.get('KEYCLOAK_REALM')}/protocol/openid-connect/auth'
        '?client_id=${dotenv.get('CLIENT_ID')}'
        '&response_type=code'
        '&scope=openid profile email'
        '&kc_idp_hint=$provider'
        '&code_challenge_method=S256'
        '&code_challenge=$challenge'
        '&redirect_uri=com.livepoised.app://callback';
  }

  Future<bool> exchangeCodeForToken(String code) async {
    try {
      final String url =
          '${dotenv.get('KEYCLOAK_URL')}/realms/${dotenv.get('KEYCLOAK_REALM')}/protocol/openid-connect/token';

      // The same verifier used in getSocialLoginUrl
      const verifier = 'livepoised_social_auth_verifier_consistent';

      final response = await _dio.post(
        url,
        data: {
          'client_id': dotenv.get('CLIENT_ID'),
          'client_secret': dotenv.get('CLIENT_SECRET'),
          'grant_type': 'authorization_code',
          'code': code,
          'code_verifier': verifier,
          'redirect_uri': 'com.livepoised.app://callback',
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
      print('Token Exchange Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    try {
      if (refreshToken != null) {
        final String url =
            '${dotenv.get('KEYCLOAK_URL')}/realms/${dotenv.get('KEYCLOAK_REALM')}/protocol/openid-connect/logout';

        await _dio.post(
          url,
          data: {
            'client_id': dotenv.get('CLIENT_ID'),
            'client_secret': dotenv.get('CLIENT_SECRET'),
            'refresh_token': refreshToken,
          },
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ),
        );
      }
    } catch (e) {
      print('Server Logout Error: $e');
    } finally {
      await _storage.clearAll();
    }
  }

  String getRegistrationUrl() {
    // S256 PKCE is required by the Keycloak server configuration
    const verifier = 'livepoised_registration_verifier_consistent_for_webview';
    
    // Generate S256 Challenge
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    final challenge = base64Url.encode(digest.bytes).replaceAll('=', '');
    
    return '${dotenv.get('KEYCLOAK_URL')}/realms/${dotenv.get('KEYCLOAK_REALM')}/protocol/openid-connect/registrations'
        '?client_id=${dotenv.get('CLIENT_ID')}'
        '&response_type=code'
        '&scope=openid'
        '&code_challenge_method=S256'
        '&code_challenge=$challenge'
        '&redirect_uri=com.livepoised.app://callback';
  }
}
