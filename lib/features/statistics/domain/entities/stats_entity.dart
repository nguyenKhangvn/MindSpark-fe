import 'package:equatable/equatable.dart';

class UserStatsEntity extends Equatable {
  final String userId;
  final int
      cardsMastered; // Đổi từ totalCards sang cardsMastered cho đúng nghĩa
  final int cardsReviewed;
  final int streak;
  final double accuracy;
  final int totalPoints; // Thêm trường này để hiển thị điểm số user

  const UserStatsEntity({
    required this.userId,
    required this.cardsMastered,
    required this.cardsReviewed,
    required this.streak,
    required this.accuracy,
    required this.totalPoints,
  });

  @override
  List<Object?> get props => [
        userId,
        cardsMastered,
        cardsReviewed,
        streak,
        accuracy,
        totalPoints,
      ];
}

class LeaderboardEntryEntity extends Equatable {
  final String userId;
  final String username;
  final int
      totalPoints; // Đổi từ score sang totalPoints cho đồng nhất với UserStats
  final int rank;

  const LeaderboardEntryEntity({
    required this.userId,
    required this.username,
    required this.totalPoints,
    required this.rank,
  });

  @override
  List<Object?> get props => [userId, username, totalPoints, rank];
}

class AchievementEntity extends Equatable {
  final String id;
  final String userId;
  final String achievementType;
  final DateTime unlockedAt;
  final bool notified;
  final String? title; // From backend metadata
  final String? description; // From backend metadata
  final String? icon; // From backend metadata (emoji)
  final String? category; // From backend metadata

  const AchievementEntity({
    required this.id,
    required this.userId,
    required this.achievementType,
    required this.unlockedAt,
    required this.notified,
    this.title,
    this.description,
    this.icon,
    this.category,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        achievementType,
        unlockedAt,
        notified,
        title,
        description,
        icon,
        category,
      ];

  /// Helper: Get display name (use backend title or fallback)
  String get displayName => title ?? achievementType;

  /// Helper: Get description text (use backend description or fallback)
  String get descriptionText => description ?? 'Achievement unlocked';

  /// Helper: Get icon emoji (use backend icon or default)
  String get iconEmoji => icon ?? '🏆';
}
