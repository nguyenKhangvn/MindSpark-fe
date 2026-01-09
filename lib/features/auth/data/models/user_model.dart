import '../../domain/entities/user_entity.dart';

/// User Model - Data layer
/// Handles JSON serialization
/// Actual response from POST /auth/login:
/// {
///   "accessToken": "eyJ...",
///   "refreshToken": "eyJ...",
///   "user": {
///     "id": "2594dd6f-...",
///     "email": "user@example.com",
///     "name": "John Doe",
///     "avatar": null
///   }
/// }
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatar,
  });

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
    };
  }
}

/// Auth Response Model
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel? user; // Nullable for refresh token response

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    this.user, // Optional
  });

  /// From JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null, // Handle null user for refresh response
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (user != null) 'user': user!.toJson(), // Only include if not null
    };
  }

  /// Convert to Entity
  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user, // UserModel là con của UserEntity nên truyền thẳng được
    );
  }
}
