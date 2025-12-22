import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Auth State - Presentation layer
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated state (login/register success)
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final String message;

  const AuthAuthenticated({required this.user, this.message = 'Success'});

  @override
  List<Object?> get props => [user, message];
}

/// Unauthenticated state (logout)
class AuthUnauthenticated extends AuthState {
  final String message;

  const AuthUnauthenticated({this.message = 'Logged out'});

  @override
  List<Object?> get props => [message];
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profile loaded state
class ProfileLoaded extends AuthState {
  final UserEntity user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}
