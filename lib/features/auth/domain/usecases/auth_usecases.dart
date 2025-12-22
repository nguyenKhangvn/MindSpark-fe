import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Register UseCase
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<String, AuthResponseEntity>> call({
    required String email,
    required String password,
    required String name,
  }) {
    return repository.register(
      email: email,
      password: password,
      name: name,
    );
  }
}

/// Login UseCase
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, AuthResponseEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}

/// Logout UseCase
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<String, void>> call() {
    return repository.logout();
  }
}

/// Get Profile UseCase
class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<String, UserEntity>> call() {
    return repository.getProfile();
  }
}

/// Check Authentication UseCase
class IsAuthenticatedUseCase {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  Future<bool> call() {
    return repository.isAuthenticated();
  }
}

/// Refresh Token UseCase
/// Used internally by DioApiClient when access token expires
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<String, AuthResponseEntity>> call() {
    return repository.refreshToken();
  }
}
