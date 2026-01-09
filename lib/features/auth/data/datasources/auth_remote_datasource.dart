import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_api_client.dart';
import '../models/user_model.dart';

/// Auth Remote DataSource - Data layer
/// Handles all HTTP requests to auth service
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getProfile();

  Future<AuthResponseModel> refreshToken(String refreshToken);
}

/// Implementation of Auth Remote DataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await apiClient.post('/auth/logout');
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.get('/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    if (kDebugMode) {
      print('🌐 [RemoteDataSource] POST /auth/refresh');
    }

    // Use postWithoutInterceptor to avoid circular loop
    final response = await apiClient.postWithoutInterceptor(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    if (kDebugMode) {
      print('📥 [RemoteDataSource] Got response: ${response.statusCode}');
      print('   Data keys: ${response.data?.keys}');
    }

    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
