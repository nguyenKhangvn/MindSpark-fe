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

  const AchievementEntity({
    required this.id,
    required this.userId,
    required this.achievementType,
    required this.unlockedAt,
    required this.notified,
  });

  @override
  List<Object?> get props =>
      [id, userId, achievementType, unlockedAt, notified];

  /// Helper: Get display name for achievement type
  String get displayName {
    switch (achievementType) {
      case 'FIRST_DECK':
        return 'First Deck Created';
      case 'FIRST_CARD':
        return 'First Card Created';
      case 'MASTER_10_CARDS':
        return 'Master 10 Cards';
      case 'MASTER_100_CARDS':
        return 'Master 100 Cards';
      case 'MASTER_1000_CARDS':
        return 'Master 1000 Cards';
      case 'STREAK_7_DAYS':
        return '7 Day Streak';
      case 'STREAK_30_DAYS':
        return '30 Day Streak';
      case 'STREAK_100_DAYS':
        return '100 Day Streak';
      case 'EARLY_BIRD':
        return 'Early Bird';
      case 'NIGHT_OWL':
        return 'Night Owl';
      case 'SPEED_DEMON':
        return 'Speed Demon';
      case 'DEDICATED':
        return 'Dedicated Learner';
      default:
        return achievementType;
    }
  }

  /// Helper: Get description for achievement type
  String get description {
    switch (achievementType) {
      case 'FIRST_DECK':
        return 'Created your first deck';
      case 'FIRST_CARD':
        return 'Created your first card';
      case 'MASTER_10_CARDS':
        return 'Mastered 10 flashcards';
      case 'MASTER_100_CARDS':
        return 'Mastered 100 flashcards';
      case 'MASTER_1000_CARDS':
        return 'Mastered 1000 flashcards';
      case 'STREAK_7_DAYS':
        return 'Studied for 7 days in a row';
      case 'STREAK_30_DAYS':
        return 'Studied for 30 days in a row';
      case 'STREAK_100_DAYS':
        return 'Studied for 100 days in a row';
      case 'EARLY_BIRD':
        return 'Studied before 8 AM';
      case 'NIGHT_OWL':
        return 'Studied after 10 PM';
      case 'SPEED_DEMON':
        return 'Completed 50 cards in one session';
      case 'DEDICATED':
        return 'Studied every day for a month';
      default:
        return 'Achievement unlocked';
    }
  }
}
