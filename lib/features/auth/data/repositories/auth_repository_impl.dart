import 'package:dartz/dartz.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart'; // Chứa cả UserEntity và AuthResponseEntity
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Auth Repository Implementation - Data layer
/// Implements domain repository interface
/// Handles error mapping and token storage
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<String, AuthResponseEntity>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );

      // Save tokens
      await tokenStorage.saveAccessToken(response.accessToken);
      await tokenStorage.saveRefreshToken(response.refreshToken);
      return Right(response.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, AuthResponseEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await tokenStorage.saveAccessToken(response.accessToken);
      await tokenStorage.saveRefreshToken(response.refreshToken);
      return Right(response.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      // 1. Cố gắng báo server (tốt nhất là làm được)
      await remoteDataSource.logout();
    } catch (e) {
      // Nếu lỗi mạng/server thì chỉ log ra, KHÔNG return Left ngay
      print("Remote logout failed: $e");
    } finally {
      // 2. QUAN TRỌNG: Luôn luôn xóa token trong máy
      // Dù bước 1 thành công hay thất bại, bước này vẫn chạy nhờ 'finally'
      await tokenStorage.clearTokens();
    }

    // Luôn trả về thành công để UI chuyển về màn Login
    return const Right(null);
  }

  @override
  Future<Either<String, UserEntity>> getProfile() async {
    try {
      final userModel = await remoteDataSource.getProfile();
      return Right(userModel);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await tokenStorage.hasToken();
  }

  @override
  Future<Either<String, AuthResponseEntity>> refreshToken() async {
    try {
      final currentRefreshToken = await tokenStorage.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        return const Left('No refresh token available');
      }

      final response = await remoteDataSource.refreshToken(currentRefreshToken);

      // Save new tokens
      await tokenStorage.saveAccessToken(response.accessToken);
      await tokenStorage.saveRefreshToken(response.refreshToken);

      return Right(response.toEntity());
    } catch (e) {
      // Clear tokens on refresh failure
      await tokenStorage.clearTokens();
      return Left(_handleError(e));
    }
  }

  /// Handle errors and return user-friendly message
  String _handleError(dynamic error) {
    final eString = error.toString();
    if (eString.contains('401')) {
      return 'Invalid credentials';
    } else if (eString.contains('400')) {
      return 'Invalid request';
    } else if (eString.contains('404')) {
      return 'Service not found';
    } else if (eString.contains('timeout')) {
      return 'Connection timeout';
    } else {
      return eString.replaceAll('Exception:', '').trim();
    }
  }
}
