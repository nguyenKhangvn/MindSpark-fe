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
      return 'http://10.0.2.2:3000/api/v1'; // ✅ FIX: Gateway port 3000
    return 'http://localhost:3000/api/v1'; // ✅ FIX: Gateway port 3000
  }

  // Ưu tiên biến môi trường nếu có
  static const String envBaseUrl = String.fromEnvironment('API_BASE_URL');

  late final Dio _dio;
  late final Dio _tokenDio; // 2. KHAI BÁO BIẾN NÀY (Bạn đang thiếu dòng này)
  final TokenStorage _tokenStorage;

  Future<bool> Function()? onRefreshToken;

  // Flag to prevent concurrent refresh attempts
  bool _isRefreshing = false;

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
            // Prevent concurrent refresh attempts
            if (_isRefreshing) {
              if (kDebugMode)
                print('⏳ Refresh already in progress, rejecting request');
              return handler.next(error);
            }

            if (onRefreshToken != null) {
              _isRefreshing = true;
              try {
                if (kDebugMode) print('🔄 Starting token refresh...');

                // Trigger refresh token flow
                final isSuccess = await onRefreshToken!();

                if (isSuccess) {
                  final newToken = await _tokenStorage.getAccessToken();

                  if (kDebugMode)
                    print('✅ Token refreshed successfully, retrying request');

                  // Update token for the failed request
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';

                  // Retry the original request
                  final response = await _dio.fetch(error.requestOptions);
                  _isRefreshing = false;
                  return handler.resolve(response);
                } else {
                  if (kDebugMode) print('❌ Token refresh returned false');
                }
              } catch (e) {
                if (kDebugMode) print('⚠️ Token refresh exception: $e');
              } finally {
                _isRefreshing = false;
              }
            }

            // Refresh failed or no callback -> Clear tokens
            if (kDebugMode) print('🧹 Clearing tokens due to failed refresh');
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
