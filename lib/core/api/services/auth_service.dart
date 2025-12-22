import '../api_client.dart';
import '../models/auth_models.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'username': username,
      },
      includeAuth: false,
    );

    final data = _apiClient.handleResponse(response);

    // Save tokens
    if (data['accessToken'] != null) {
      await _apiClient.setToken(data['accessToken']);
    }

    return AuthResponse.fromJson(data);
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      includeAuth: false,
    );

    final data = _apiClient.handleResponse(response);

    // Save tokens
    if (data['accessToken'] != null) {
      await _apiClient.setToken(data['accessToken']);
    }

    return AuthResponse.fromJson(data);
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh',
      body: {
        'refreshToken': refreshToken,
      },
      includeAuth: false,
    );

    final data = _apiClient.handleResponse(response);

    // Update access token
    if (data['accessToken'] != null) {
      await _apiClient.setToken(data['accessToken']);
    }

    return AuthResponse.fromJson(data);
  }

  /// Logout user
  Future<void> logout() async {
    final response = await _apiClient.post(
      '/auth/logout',
      includeAuth: true,
    );

    _apiClient.handleResponse(response);

    // Clear tokens
    await _apiClient.clearToken();
  }

  /// Health check for auth service
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _apiClient.get('/auth/health', includeAuth: false);
    return _apiClient.handleResponse(response);
  }

  /// Get current user profile
  Future<User> getProfile() async {
    final response = await _apiClient.get(
      '/auth/me',
      includeAuth: true,
    );

    final data = _apiClient.handleResponse(response);
    return User.fromJson(data);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    await _apiClient.initialize();
    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }
}
