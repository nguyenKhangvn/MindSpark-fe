import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

/// Auth Repository Interface - Domain layer
/// Defines what auth operations are available
abstract class AuthRepository {
  Future<Either<String, AuthResponseEntity>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<String, AuthResponseEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<String, void>> logout();

  Future<Either<String, UserEntity>> getProfile();

  Future<bool> isAuthenticated();

  Future<Either<String, AuthResponseEntity>> refreshToken();
}
