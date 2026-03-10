import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_endpoints.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio springBoot;
  late final Dio fastAPI;

  DioClient._internal() {
    springBoot = _createDio(ApiEndpoints.baseUrlSpringBoot);
    fastAPI = _createDio(ApiEndpoints.baseUrlFastAPI);
  }

  Dio _createDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(SecureStorageService()));
    
    // Dev only logging
    if (!dotenv.get('BASE_URL_SB').contains('prod')) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ));
    }
    
    return dio;
  }
}

