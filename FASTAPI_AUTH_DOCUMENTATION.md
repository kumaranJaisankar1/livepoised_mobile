# LivePoised Mobile — Keycloak & FastAPI Authentication Integration Guide

> **App**: `livepoised_mobile` (Flutter / Dart)  
> **Backend**: FastAPI (`livepoisedapi`) + Keycloak OIDC Server  
> **Auth Mechanism**: OAuth 2.0 / OpenID Connect (OIDC) JWT with Automatic Token Refresh  
> **Authored**: 2026-08-20  

---

## 1. Executive Summary & Authentication Architecture

The mobile application authenticates against the Keycloak IAM server to receive signed RS256 JSON Web Tokens (JWTs). These tokens are stored securely on the mobile device and attached as HTTP `Authorization: Bearer <token>` headers on all API requests sent to the FastAPI backend (`livepoisedapi`).

```
┌─────────────────────────┐        ┌─────────────────────────┐        ┌─────────────────────────┐
│ Flutter Mobile App      │        │ Keycloak IAM Server     │        │ FastAPI Backend         │
│ (livepoised_mobile)     │        │ (auth.vannadev.com)     │        │ (livepoisedapi)         │
└────────────┬────────────┘        └────────────┬────────────┘        └────────────┬────────────┘
             │                                  │                                  │
             ├────── 1. Auth Request (PKCE) ───►│                                  │
             │◄───── 2. JWTs (Access/Refresh) ──┤                                  │
             │                                  │                                  │
             │ ── Stores tokens in SecureStorage│                                  │
             │                                  │                                  │
             ├────── 3. API Request + Bearer JWT ─────────────────────────►│
             │                                  │                          │ (Validates JWT signature
             │                                  │                          │  against Keycloak JWKS)
             │◄───── 4. 200 OK / Response Data ────────────────────────────┤
```

---

## 2. Environment Configuration

Add Keycloak and FastAPI configurations to `.env.dev` / `.env.prod`:

```env
# Keycloak OpenID Connect Configuration
KEYCLOAK_ISSUER=https://auth.vannadev.com/realms/livepoised
KEYCLOAK_CLIENT_ID=livepoised
KEYCLOAK_REDIRECT_URI=com.livepoised.app://oauth-redirect

# FastAPI Base URL
FASTAPI_BASE_URL=http://10.0.2.2:8000
```

---

## 3. Required Flutter Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # OAuth2 / OIDC authentication with PKCE support
  flutter_appauth: ^6.0.0

  # Encrypted secure storage for Tokens (Keychain on iOS, EncryptedSharedPreferences on Android)
  flutter_secure_storage: ^9.0.0

  # HTTP client & interceptors
  dio: ^5.4.0

  # State Management
  get: ^4.6.6
```

---

## 4. Complete Dart Auth Service (`AuthService.dart`)

**File**: `lib/features/auth/data/auth_service.dart`

This service manages login, token storage, silent background token refresh, and HTTP Bearer header injection:

```dart
import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String issuer = 'https://auth.vannadev.com/realms/livepoised';
  static const String clientId = 'livepoised';
  static const String redirectUrl = 'com.livepoised.app://oauth-redirect';

  final accessToken  = Rxn<String>();
  final idToken      = Rxn<String>();
  final refreshToken = Rxn<String>();
  final isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredTokens();
  }

  // ── Load Cached Tokens on App Startup ─────────────────────────────
  Future<void> _loadStoredTokens() async {
    final token = await _storage.read(key: 'access_token');
    final refresh = await _storage.read(key: 'refresh_token');

    if (token != null && refresh != null) {
      accessToken.value  = token;
      refreshToken.value = refresh;
      isAuthenticated.value = true;
    }
  }

  // ── Browser PKCE OIDC Login ────────────────────────────────────────
  Future<bool> login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      if (result != null && result.accessToken != null) {
        await _saveTokens(
          result.accessToken!,
          result.refreshToken,
          result.idToken,
        );
        return true;
      }
    } catch (e) {
      print('[AuthService] Login Error: $e');
    }
    return false;
  }

  // ── Direct Credential Login (Fallback) ─────────────────────────────
  Future<bool> loginWithCredentials(String username, String password) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '$issuer/protocol/openid-connect/token',
        data: {
          'grant_type': 'password',
          'client_id': clientId,
          'username': username,
          'password': password,
          'scope': 'openid profile email offline_access',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(
          data['access_token'],
          data['refresh_token'],
          data['id_token'],
        );
        return true;
      }
    } catch (e) {
      print('[AuthService] Credentials Login Error: $e');
    }
    return false;
  }

  // ── Refresh Access Token ───────────────────────────────────────────
  Future<String?> refreshAccessToken() async {
    final currentRefresh = refreshToken.value;
    if (currentRefresh == null) return null;

    try {
      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          refreshToken: currentRefresh,
        ),
      );

      if (result != null && result.accessToken != null) {
        await _saveTokens(
          result.accessToken!,
          result.refreshToken ?? currentRefresh,
          result.idToken,
        );
        return result.accessToken;
      }
    } catch (e) {
      print('[AuthService] Token Refresh Error: $e');
      logout();
    }
    return null;
  }

  // ── Save Tokens Securely ───────────────────────────────────────────
  Future<void> _saveTokens(String access, String? refresh, String? id) async {
    accessToken.value  = access;
    refreshToken.value = refresh;
    idToken.value      = id;
    isAuthenticated.value = true;

    await _storage.write(key: 'access_token', value: access);
    if (refresh != null) await _storage.write(key: 'refresh_token', value: refresh);
    if (id != null) await _storage.write(key: 'id_token', value: id);
  }

  // ── Logout & Revoke ────────────────────────────────────────────────
  Future<void> logout() async {
    accessToken.value  = null;
    refreshToken.value = null;
    idToken.value      = null;
    isAuthenticated.value = false;

    await _storage.deleteAll();
  }
}
```

---

## 5. Dio HTTP Interceptor (`ApiClient.dart`)

**File**: `lib/core/network/api_client.dart`

Automatically attaches `Authorization: Bearer <access_token>` to every request and handles 401 token refresh retries:

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../features/auth/data/auth_service.dart';

class ApiClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final auth = Get.find<AuthService>();
          if (auth.accessToken.value != null) {
            options.headers['Authorization'] = 'Bearer ${auth.accessToken.value}';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final auth = Get.find<AuthService>();
            final newAccessToken = await auth.refreshAccessToken();

            if (newAccessToken != null) {
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              try {
                final response = await dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
```

---

## 6. FastAPI Claims & Verification Summary

When `livepoisedapi` receives the Bearer token:

| Keycloak JWT Claim | Expected Value | FastAPI Validation Rule |
| :--- | :--- | :--- |
| `iss` (Issuer) | `https://auth.vannadev.com/realms/livepoised` | Matches `settings.jwt_issuer` |
| `azp` (Authorized Party) | `livepoised` | Matches `settings.jwt_audience` |
| `sub` (Subject) | `c0a80101-0000-0000-0000-000000000001` | Map to `CurrentUser.user_id` |
| `preferred_username` | `sam_warrior` | Map to `CurrentUser.username` |

---

## 7. Developer Verification Checklist

- [ ] Add `flutter_appauth`, `flutter_secure_storage`, and `dio` to `pubspec.yaml`.
- [ ] Configure Android `scheme` in `android/app/build.gradle` for PKCE redirect (`com.livepoised.app`).
- [ ] Test direct credential login with `loginWithCredentials("sam_warrior", "password")`.
- [ ] Verify HTTP requests send header: `Authorization: Bearer eyJhbGci...`.
- [ ] Test 401 token refresh behavior when access token expires after 5 minutes.
