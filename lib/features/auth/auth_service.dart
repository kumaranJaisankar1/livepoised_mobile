import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livepoised_mobile/core/storage/secure_storage_service.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import 'package:livepoised_mobile/core/network/dio_client.dart';
import 'package:livepoised_mobile/core/models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient().springBoot;
  final SecureStorageService _storage = SecureStorageService();
  final FlutterAppAuth _appAuth = const FlutterAppAuth();


  Future<bool> loginWithCredentials(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.tokenEndpoint,
        data: {
          'client_id': ApiEndpoints.clientId,
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
        final userProfile = _parseUserProfileFromIdToken(data['id_token']);
        await _storage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          idToken: data['id_token'],
          username: username,
          userProfile: userProfile,
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

  Future<bool> signInWithBrowser() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          ApiEndpoints.clientId,
          ApiEndpoints.redirectUri,
          discoveryUrl: ApiEndpoints.discoveryUrl,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      if (result != null && result.accessToken != null) {
        await _storage.saveTokens(
          accessToken: result.accessToken!,
          refreshToken: result.refreshToken,
          idToken: result.idToken,
          userProfile: _parseUserProfileFromIdToken(result.idToken),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Browser Login Error: $e');
      return false;
    }
  }

  UserModel? _parseUserProfileFromIdToken(String? idToken) {
    if (idToken == null) return null;
    try {
      final parts = idToken.split('.');
      if (parts.length < 2) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = json.decode(payload);
      
      // Ensure we mapping Keycloak standard claims to our model
      return UserModel.fromJson({
        'sub': data['sub'],
        'preferred_username': data['preferred_username'] ?? data['sub'],
        'email': data['email'],
        'given_name': data['given_name'],
        'family_name': data['family_name'],
        'name': data['name'],
      });
    } catch (e) {
      print('Error parsing ID token: $e');
      return null;
    }
  }

  Future<bool> syncWithBackend() async {
    final token = await _storage.getAccessToken();
    if (token == null) return false;

    try {
      final response = await _dio.post(
        ApiEndpoints.googleSync,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Backend synchronization successful');
        return true;
      }
      print('Backend synchronization failed: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      print('Backend Sync Error: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      print('Backend Sync Error: $e');
      return false;
    }
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        ApiEndpoints.tokenEndpoint,
        data: {
          'client_id': ApiEndpoints.clientId,
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
        final userProfile = _parseUserProfileFromIdToken(data['id_token']);
        await _storage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          idToken: data['id_token'],
          userProfile: userProfile,
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
    
    return '${ApiEndpoints.authEndpoint}'
        '?client_id=${ApiEndpoints.clientId}'
        '&response_type=code'
        '&scope=openid profile email'
        '&kc_idp_hint=$provider'
        '&code_challenge_method=S256'
        '&code_challenge=$challenge'
        '&redirect_uri=${ApiEndpoints.redirectUri}';
  }

  Future<bool> exchangeCodeForToken(String code) async {
    try {
      // The same verifier used in getSocialLoginUrl
      const verifier = 'livepoised_social_auth_verifier_consistent';

      final response = await _dio.post(
        ApiEndpoints.tokenEndpoint,
        data: {
          'client_id': ApiEndpoints.clientId,
          'client_secret': dotenv.get('CLIENT_SECRET'),
          'grant_type': 'authorization_code',
          'code': code,
          'code_verifier': verifier,
          'redirect_uri': ApiEndpoints.redirectUri,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final userProfile = _parseUserProfileFromIdToken(data['id_token']);
        await _storage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          idToken: data['id_token'],
          userProfile: userProfile,
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
        await _dio.post(
          ApiEndpoints.logoutEndpoint,
          data: {
            'client_id': ApiEndpoints.clientId,
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
    
    return '${ApiEndpoints.registrationEndpoint}'
        '?client_id=${ApiEndpoints.clientId}'
        '&response_type=code'
        '&scope=openid'
        '&code_challenge_method=S256'
        '&code_challenge=$challenge'
        '&redirect_uri=${ApiEndpoints.redirectUri}';
  }
}

