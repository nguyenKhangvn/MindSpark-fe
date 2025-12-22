import '../../domain/entities/stats_entity.dart';

/// User Stats Model
class UserStatsModel {
  final String userId;
  final int totalCards;
  final int cardsReviewed;
  final int streak;
  final double accuracy;

  UserStatsModel({
    required this.userId,
    required this.totalCards,
    required this.cardsReviewed,
    required this.streak,
    required this.accuracy,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId'] as String? ?? '',
      
      // Backend trả về cardsMastered, không phải totalCards
      totalCards: (json['cardsMastered'] as num?)?.toInt() ?? 0,
      
      // Backend có thể tính từ dailyStats hoặc activityLogs
      cardsReviewed: (json['cardsReviewed'] as num?)?.toInt() ?? 0,
      
      // Backend trả về currentStreak
      streak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      
      // Accuracy cần tính từ dailyStats (correctAnswers / total)
      // Tạm thời hardcode 0.0, cần backend tính toán
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  UserStatsEntity toEntity() {
    return UserStatsEntity(
      userId: userId,
      totalCards: totalCards,
      cardsReviewed: cardsReviewed,
      streak: streak,
      accuracy: accuracy,
    );
  }
}

/// Leaderboard Entry Model
class LeaderboardEntryModel {
  final String userId;
  final String username;
  final int score;
  final int rank;

  LeaderboardEntryModel({
    required this.userId,
    required this.username,
    required this.score,
    required this.rank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      // SỬA: Phòng hờ null string
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? 'Unknown',

      // SỬA: Ép kiểu an toàn về 0 nếu null
      score: (json['score'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );
  }

  LeaderboardEntryEntity toEntity() {
    return LeaderboardEntryEntity(
      userId: userId,
      username: username,
      score: score,
      rank: rank,
    );
  }
}
