import '../models/auth_models.dart';
import '../../network/dio_api_client.dart';
import '../../storage/token_storage.dart';

/// Auth service using Dio with callback-based token refresh
class AuthServiceDio {
  final DioApiClient _dioClient;
  final TokenStorage _tokenStorage;

  AuthServiceDio(this._dioClient, this._tokenStorage);

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _dioClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'username': username,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);

    // Save tokens to storage
    await _tokenStorage.saveAccessToken(authResponse.accessToken);
    await _tokenStorage.saveRefreshToken(authResponse.refreshToken);

    return authResponse;
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);

    // Save tokens to storage
    await _tokenStorage.saveAccessToken(authResponse.accessToken);
    await _tokenStorage.saveRefreshToken(authResponse.refreshToken);

    return authResponse;
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);

    // Update tokens in storage
    await _tokenStorage.saveAccessToken(authResponse.accessToken);
    await _tokenStorage.saveRefreshToken(authResponse.refreshToken);

    return authResponse;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _dioClient.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Always clear tokens
      await _tokenStorage.clearAll();
    }
  }

  /// Health check for auth service
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _dioClient.get('/auth/health');
    return response.data;
  }

  /// Get current user profile
  Future<User> getProfile() async {
    final response = await _dioClient.get('/auth/me');
    return User.fromJson(response.data);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }
}
