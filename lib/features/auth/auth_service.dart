import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livepoised_mobile/core/storage/secure_storage_service.dart';
import 'package:livepoised_mobile/core/constants/api_endpoints.dart';
import 'package:livepoised_mobile/core/network/dio_client.dart';
import 'package:livepoised_mobile/core/models/user_model.dart';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';


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
          "client_secret": dotenv.get('CLIENT_SECRET'),
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
      developer.log('Direct Login Error: $message');
      throw message;
    } catch (e) {
      developer.log('Direct Login Error: $e');
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
      developer.log('Browser Login Error: $e');
      return false;
    }
  }



  Future<bool> signInWithSocialProvider(String provider) async {
    if (provider.toLowerCase() == 'google') {
      return _signInWithGoogleNative();
    }
    
    // Fallback or other providers can still use browser flow if needed in the future
    throw UnsupportedError('Only native google login is supported currently.');
  }

  Future<bool> _signInWithGoogleNative() async {
    try {
      developer.log('Starting Native Google Sign-In...');

      // google_sign_in v6 API - exposes accessToken needed for Keycloak Token Exchange
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '1044735544019-oakt4j9pb0ob7dkd5oe3urtfspivanu5.apps.googleusercontent.com',
      );

      // 1. Trigger Google login
      // Sign out first to clear cached session and force account picker to appear
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('Google sign-in was cancelled by the user');
        return false;
      }

      developer.log('Google User Authenticated: ${googleUser.email}');

      // 2. Get tokens — v6 exposes both accessToken and idToken
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        developer.log('Failed to retrieve Google Access Token.');
        return false;
      }

      developer.log('Google Access Token retrieved. Exchanging with Keycloak...');

      // 3. Token Exchange with Keycloak using the real Google Access Token
      final response = await _dio.post(
        ApiEndpoints.tokenEndpoint,
        data: {
          'client_id': ApiEndpoints.clientId,
          'grant_type': 'urn:ietf:params:oauth:grant-type:token-exchange',
          'subject_token': accessToken,
          'subject_token_type': 'urn:ietf:params:oauth:token-type:access_token',
          'subject_issuer': 'google',
          'client_secret': dotenv.get('CLIENT_SECRET'),
          'scope': 'openid profile email offline_access',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      // 4. Parse and store Keycloak tokens
      if (response.statusCode == 200) {
        final data = response.data;
        developer.log('Keycloak Token Exchange successful');
        final userProfile = _parseUserProfileFromIdToken(data['id_token']);
        await _storage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          idToken: data['id_token'],
          userProfile: userProfile,
        );
        return true;
      }
      developer.log('Keycloak token exchange failed with status: \${response.statusCode}');
      return false;

    } on DioException catch (e) {
      final message = e.response?.data?['error_description'] ?? e.message;
      developer.log('Keycloak Token Exchange DioError: \$message');
      throw message;
    } catch (e) {
      developer.log('Google Sign-In Error: \$e');
      rethrow;
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
      developer.log('Error parsing ID token: $e');
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
        developer.log('Backend synchronization successful');
        return true;
      }
      developer.log('Backend synchronization failed: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      developer.log('Backend Sync Error: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      developer.log('Backend Sync Error: $e');
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
      developer.log('Token Refresh Error: $e');
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
      developer.log('Token Exchange Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    try {
      if (refreshToken != null) {
        // client_secret is required for Keycloak to invalidate the server-side session
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
        developer.log('Keycloak session successfully terminated');
      }

      // Also sign out from Google to clear the local account cache
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        developer.log('Google Sign-Out successful');
      } catch (_) {}

    } catch (e) {
      developer.log('Server Logout Error: $e');
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
