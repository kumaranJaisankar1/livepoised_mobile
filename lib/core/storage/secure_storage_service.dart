import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:livepoised_mobile/core/models/user_model.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _idTokenKey = 'id_token';

  static const _usernameKey = 'username';
  static const _userProfileKey = 'user_profile';
  
  static const _rememberMeKey = 'remember_me';
  static const _savedUsernameKey = 'saved_username';
  static const _savedPasswordKey = 'saved_password';

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    String? username,
    UserModel? userProfile,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (idToken != null) {
      await _storage.write(key: _idTokenKey, value: idToken);
    }
    if (username != null) {
      await _storage.write(key: _usernameKey, value: username);
    }
    if (userProfile != null) {
      await _storage.write(key: _userProfileKey, value: json.encode(userProfile.toJson()));
    }
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  Future<String?> getIdToken() async => await _storage.read(key: _idTokenKey);
  Future<String?> getUsername() async => await _storage.read(key: _usernameKey);

  Future<UserModel?> getUserProfile() async {
    final profileStr = await _storage.read(key: _userProfileKey);
    if (profileStr == null) return null;
    try {
      return UserModel.fromJson(json.decode(profileStr) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async => await _storage.deleteAll();

  // Remember Me Methods
  Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _rememberMeKey, value: value.toString());
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  Future<void> saveRememberedCredentials(String username, String password) async {
    await _storage.write(key: _savedUsernameKey, value: username);
    await _storage.write(key: _savedPasswordKey, value: password);
  }

  Future<Map<String, String?>> getRememberedCredentials() async {
    final username = await _storage.read(key: _savedUsernameKey);
    final password = await _storage.read(key: _savedPasswordKey);
    return {'username': username, 'password': password};
  }

  Future<void> clearRememberedCredentials() async {
    await _storage.delete(key: _savedUsernameKey);
    await _storage.delete(key: _savedPasswordKey);
  }
}
