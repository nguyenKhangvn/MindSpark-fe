import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/token_storage.dart';
import '../config/api_config.dart';

/// Dio client with automatic token refresh interceptor
/// Handles 401 errors by refreshing tokens and retrying requests
class DioClientWithInterceptor {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final VoidCallback? onUnauthorized;

  // Concurrency control
  bool _isRefreshing = false;
  final List<RequestOptions> _requestQueue = [];

  DioClientWithInterceptor(
    this._tokenStorage, {
    this.onUnauthorized,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.fullBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('🌐 [Dio] $obj'),
      ));
    }

    // Add auto-refresh token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  /// Get Dio instance for direct usage
  Dio get dio => _dio;

  /// Interceptor: Attach access token before sending request
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    // Get access token from storage
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      if (kDebugMode) {
        debugPrint('🔑 [Interceptor] Attached access token');
      }
    }

    return handler.next(options);
  }

  /// Interceptor: Handle 401 error with automatic token refresh
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (error.response?.statusCode != 401) {
      return handler.next(error);
    }

    if (kDebugMode) {
      debugPrint(' [Interceptor] 401 Unauthorized - Starting token refresh');
    }

    // Prevent concurrent refresh requests
    if (_isRefreshing) {
      if (kDebugMode) {
        debugPrint('⏳ [Interceptor] Refresh in progress, queueing request');
      }
      // Add to queue and wait
      _requestQueue.add(error.requestOptions);
      return;
    }

    _isRefreshing = true;

    try {
      // Get refresh token from storage
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          debugPrint(' [Interceptor] No refresh token found - User must login');
        }
        // No refresh token available, clear all tokens and reject
        _isRefreshing = false;
        await _tokenStorage.clearAll();

        // Navigate to login screen
        if (onUnauthorized != null) {
          if (kDebugMode) {
            debugPrint('🚪 [Interceptor] Triggering navigation to login');
          }
          onUnauthorized!();
        }

        return handler.reject(error);
      }

      if (kDebugMode) {
        debugPrint('🔄 [Interceptor] Calling /auth/refresh endpoint');
        debugPrint('🔑 [Interceptor] Using refresh token from storage');
      }

      // Call refresh endpoint (use separate Dio to avoid infinite loop)
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConfig.fullBaseUrl));
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        if (kDebugMode) {
          debugPrint(' [Interceptor] Got new tokens, saving to storage');
        }

        // Save new tokens
        await _tokenStorage.saveAccessToken(newAccessToken);
        await _tokenStorage.saveRefreshToken(newRefreshToken);

        // Retry original request with new token
        error.requestOptions.headers['Authorization'] =
            'Bearer $newAccessToken';

        if (kDebugMode) {
          debugPrint('🔁 [Interceptor] Retrying original request');
        }

        final cloneReq = await _dio.fetch(error.requestOptions);

        // Process queued requests
        if (_requestQueue.isNotEmpty) {
          if (kDebugMode) {
            debugPrint(
                '📋 [Interceptor] Processing ${_requestQueue.length} queued requests');
          }

          for (var queuedRequest in _requestQueue) {
            queuedRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            try {
              await _dio.fetch(queuedRequest);
            } catch (e) {
              if (kDebugMode) {
                debugPrint(' [Interceptor] Queued request failed: $e');
              }
            }
          }
          _requestQueue.clear();
        }

        _isRefreshing = false;
        return handler.resolve(cloneReq);
      } else {
        throw DioException(
          requestOptions: error.requestOptions,
          error: 'Refresh token failed',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(' [Interceptor] Refresh failed: $e');
        debugPrint('🚪 [Interceptor] Clearing tokens - User must login again');
      }

      // Refresh failed, clear all tokens
      await _tokenStorage.clearAll();
      _requestQueue.clear();
      _isRefreshing = false;

      // Navigate to login screen
      if (onUnauthorized != null) {
        if (kDebugMode) {
          debugPrint('🚪 [Interceptor] Triggering navigation to login');
        }
        onUnauthorized!();
      }

      return handler.reject(error);
    }
  }
}
