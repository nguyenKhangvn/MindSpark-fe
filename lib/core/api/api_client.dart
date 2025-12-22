import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiClient {
  // Use centralized config
  String get baseUrl => ApiConfig.fullBaseUrl;

  final http.Client _client;
  String? _accessToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Initialize token from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  // Set authentication token
  Future<void> setToken(String token) async {
    _accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  // Clear authentication token
  Future<void> clearToken() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Get headers with authentication
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool includeAuth = true,
  }) async {
    Uri uri = Uri.parse('$baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(
          queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ));
    }

    if (ApiConfig.enableLogging) {
      developer.log('GET: $uri', name: 'ApiClient');
    }

    try {
      final response = await _client
          .get(
            uri,
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConfig.receiveTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      developer.log('GET error: $e', name: 'ApiClient', error: e);
      throw ApiException('Network error: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (ApiConfig.enableLogging) {
      developer.log('POST: $uri', name: 'ApiClient');
      if (body != null) developer.log('Body: $body', name: 'ApiClient');
    }

    try {
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.sendTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      developer.log('POST error: $e', name: 'ApiClient', error: e);
      throw ApiException('Network error: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (ApiConfig.enableLogging) {
      developer.log('PUT: $uri', name: 'ApiClient');
      if (body != null) developer.log('Body: $body', name: 'ApiClient');
    }

    try {
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.sendTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      developer.log('PUT error: $e', name: 'ApiClient', error: e);
      throw ApiException('Network error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (ApiConfig.enableLogging) {
      developer.log('DELETE: $uri', name: 'ApiClient');
    }

    try {
      final response = await _client
          .delete(
            uri,
            headers: _getHeaders(includeAuth: includeAuth),
          )
          .timeout(ApiConfig.sendTimeout);

      _logResponse(response);
      return response;
    } catch (e) {
      developer.log('DELETE error: $e', name: 'ApiClient', error: e);
      throw ApiException('Network error: $e');
    }
  }

  // Log response for debugging
  void _logResponse(http.Response response) {
    if (ApiConfig.enableLogging) {
      developer.log(
        'Response ${response.statusCode}: ${response.body.length} bytes',
        name: 'ApiClient',
      );
      if (response.statusCode >= 400) {
        developer.log('Error body: ${response.body}', name: 'ApiClient');
      }
    }
  }

  // Handle API response
  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Resource not found');
    } else if (response.statusCode == 504) {
      throw TimeoutException('Gateway timeout');
    } else {
      try {
        final error = jsonDecode(response.body);
        throw ApiException(
          error['message'] ?? error['error'] ?? 'Unknown error',
        );
      } catch (e) {
        throw ApiException('Server error: ${response.statusCode}');
      }
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}
