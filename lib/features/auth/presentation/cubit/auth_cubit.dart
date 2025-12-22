import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

/// Auth Cubit - Presentation layer
/// Manages authentication state
class AuthCubit extends Cubit<AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final IsAuthenticatedUseCase isAuthenticatedUseCase;

  AuthCubit({
    required this.registerUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.isAuthenticatedUseCase,
  }) : super(AuthInitial());

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (error) => emit(AuthError(error)),
      (authResponse) => emit(AuthAuthenticated(
        user: authResponse.user,
        message: 'Registration successful',
      )),
    );
  }

  /// Login user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (error) => emit(AuthError(error)),
      (authResponse) => emit(AuthAuthenticated(
        user: authResponse.user,
        message: 'Login successful',
      )),
    );
  }

  /// Logout user
  Future<void> logout() async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (error) => emit(AuthError(error)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Get user profile
  Future<void> getProfile() async {
    emit(AuthLoading());

    final result = await getProfileUseCase();

    result.fold(
      (error) => emit(AuthError(error)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  /// Check if user is authenticated
  Future<void> checkAuthentication() async {
    final isAuth = await isAuthenticatedUseCase();
    if (isAuth) {
      await getProfile();
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
