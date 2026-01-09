import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io'; // Import để check Platform
import '../storage/token_storage.dart';

/// Dio-based API Client with JWT authentication
class DioApiClient {
  // 1. Tự động detect localhost cho Android Emulator (QUAN TRỌNG)
  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/v1';
    if (Platform.isAndroid)
      return 'http://10.0.2.2:3002/api/v1'; // Android Emulator
    return 'http://localhost:3002/api/v1'; // iOS Simulator / Others
  }

  // Ưu tiên biến môi trường nếu có
  static const String envBaseUrl = String.fromEnvironment('API_BASE_URL');

  late final Dio _dio;
  late final Dio _tokenDio; // 2. KHAI BÁO BIẾN NÀY (Bạn đang thiếu dòng này)
  final TokenStorage _tokenStorage;

  Future<bool> Function()? onRefreshToken;

  DioApiClient(this._tokenStorage) {
    // Logic chọn URL
    final finalUrl = envBaseUrl.isNotEmpty ? envBaseUrl : _defaultBaseUrl;

    final options = BaseOptions(
      baseUrl: finalUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);
    _tokenDio = Dio(options); // 3. KHỞI TẠO NÓ (Bạn đang thiếu dòng này)

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // 4. Dùng QueuedInterceptorsWrapper (Thay vì InterceptorsWrapper thường)
    // Để khóa hàng đợi khi đang refresh token
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print(' REQUEST: ${options.method} ${options.uri}');
            if (options.data != null) print('📦 Body: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
                ' RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print(
                ' ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
            print('💬 Message: ${error.message}');
          }

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            if (onRefreshToken != null) {
              try {
                // Các request 401 đến sau sẽ phải đợi dòng này chạy xong
                final isSuccess = await onRefreshToken!();

                if (isSuccess) {
                  final newToken = await _tokenStorage.getAccessToken();

                  // Update token mới cho request bị lỗi
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';

                  // Retry request
                  final response = await _dio.fetch(error.requestOptions);
                  return handler.resolve(response);
                }
              } catch (e) {
                if (kDebugMode) print(' Token refresh failed: $e');
              }
            }
            // Refresh thất bại -> Clear token
            await _tokenStorage.clearTokens();
          }

          handler.next(error);
        },
      ),
    );
  }

  // --- METHODS ---

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Hàm này giờ đã an toàn vì _tokenDio đã được khởi tạo
  Future<Response> postWithoutInterceptor(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _tokenDio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout', 408);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final message = _extractErrorMessage(error.response?.data);
        return ApiException(message, statusCode);
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', 499);
      default:
        return ApiException('Network error: ${error.message}', 0);
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error';
    if (data is Map) {
      return data['message'] ??
          data['error'] ??
          data['detail'] ??
          'Unknown error';
    }
    return data.toString();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
