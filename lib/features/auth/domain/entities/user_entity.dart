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
  final UserEntity user;

  const AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
