import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';

/// Dio-based API Client with JWT authentication
/// Handles all HTTP requests to backend microservices
class DioApiClient {
  // Allow overriding the API base URL via --dart-define=API_BASE_URL=...
  // Defaults to localhost for web; on real devices, pass your host/LAN IP.
  static const String baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:3000/api/v1');

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  // Callback để refresh token khi gặp 401
  Future<bool> Function()? onRefreshToken;

  DioApiClient(this._tokenStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  /// Setup Dio interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Request interceptor - Attach JWT token
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('🌐 REQUEST: ${options.method} ${options.uri}');
            print('📋 Headers: ${options.headers}');
            if (options.data != null) {
              print('📦 Body: ${options.data}');
            }
          }

          handler.next(options);
        },

        // Response interceptor - Log responses
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
                ' RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
            print('📥 Data: ${response.data}');
          }
          handler.next(response);
        },

        // Error interceptor - Handle 401 and other errors
        onError: (error, handler) async {
          if (kDebugMode) {
            print(
                ' ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
            print('💬 Message: ${error.message}');
            print(' Response: ${error.response?.data}');
          }

          // Handle 401 Unauthorized - Try refresh token
          if (error.response?.statusCode == 401) {
            if (kDebugMode) {
              print(' Token expired - attempting to refresh...');
            }

            // Try to refresh token
            if (onRefreshToken != null) {
              final refreshSuccess = await onRefreshToken!();

              if (refreshSuccess) {
                // Retry the original request with new token
                try {
                  if (kDebugMode) {
                    print('🔄 Retrying request with new token...');
                  }

                  final newToken = await _tokenStorage.getAccessToken();
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';

                  final response = await _dio.fetch(error.requestOptions);
                  return handler.resolve(response);
                } catch (e) {
                  if (kDebugMode) {
                    print(' Retry failed: $e');
                  }
                  return handler.next(error);
                }
              } else {
                // Refresh failed - clear tokens
                await _tokenStorage.clearTokens();
                if (kDebugMode) {
                  print(' Token refresh failed - cleared tokens');
                }
              }
            } else {
              // No refresh callback - just clear tokens
              await _tokenStorage.clearTokens();
              if (kDebugMode) {
                print('⚠️ No refresh callback - cleared tokens');
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  /// GET request
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

  /// POST request
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

  /// POST request without interceptors (for refresh token to avoid loop)
  Future<Response> postWithoutInterceptor(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
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

  /// DELETE request
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

  /// Handle DioException and convert to custom exception
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

  /// Extract error message from response
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

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
