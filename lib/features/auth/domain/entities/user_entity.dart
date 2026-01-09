import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatar;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, email, name, avatar];
}

class AuthResponseEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final UserEntity? user; // Nullable for refresh token response

  const AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    this.user, // Optional
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
