import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _idTokenKey = 'id_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? idToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    if (idToken != null) {
      await _storage.write(key: _idTokenKey, value: idToken);
    }
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);
  Future<String?> getIdToken() async => await _storage.read(key: _idTokenKey);

  Future<void> clearAll() async => await _storage.deleteAll();
}
