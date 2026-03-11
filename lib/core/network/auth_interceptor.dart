import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../features/auth/auth_service.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  AuthInterceptor(this._storage);

  bool _isRefreshing = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If it's a 401 error and not from the token endpoint itself
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/protocol/openid-connect/token')) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final authService = Get.find<AuthService>();
          final success = await authService.refreshToken();
          
          if (success) {
            // Get the new token
            final newToken = await _storage.getAccessToken();
            
            // Update the header and retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            
            // Create a new Dio instance to retry (avoiding the interceptor loop if possible, 
            // but standard Dio.fetch works if we update headers correctly)
            final dio = Dio(); 
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } else {
            // Refresh failed, logout user
            Get.find<AuthService>().logout();
            Get.offAllNamed('/login'); // Redirect to login
          }
        } catch (e) {
          print('Error during automatic token refresh: $e');
        } finally {
          _isRefreshing = false;
        }
      }
    }
    return handler.next(err);
  }
}
