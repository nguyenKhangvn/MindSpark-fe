import '../../domain/entities/stats_entity.dart';

/// User Stats Model
class UserStatsModel {
  final String userId;
  final int cardsMastered; // Sửa tên cho đúng nghĩa
  final int cardsReviewed;
  final int streak;
  final double accuracy;
  final int totalPoints; // Thêm trường này vì Backend có trả về

  UserStatsModel({
    required this.userId,
    required this.cardsMastered,
    required this.cardsReviewed,
    required this.streak,
    required this.accuracy,
    required this.totalPoints,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['userId'] as String? ?? '',

      // Mapping đúng key từ Backend (cardsMastered)
      cardsMastered: (json['cardsMastered'] as num?)?.toInt() ?? 0,

      // Mapping đúng key từ Backend (cardsReviewed)
      cardsReviewed: (json['cardsReviewed'] as num?)?.toInt() ?? 0,

      // Mapping đúng key từ Backend (currentStreak)
      streak: (json['currentStreak'] as num?)?.toInt() ?? 0,

      // Backend trả về 'totalPoints'
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,

      // Accuracy
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  UserStatsEntity toEntity() {
    return UserStatsEntity(
      userId: userId,
      cardsMastered: cardsMastered, // Entity cũng nên đổi tên field này
      cardsReviewed: cardsReviewed,
      streak: streak,
      accuracy: accuracy,
      totalPoints: totalPoints,
    );
  }
}

/// Leaderboard Entry Model
class LeaderboardEntryModel {
  final String userId;
  final String username;
  final int totalPoints; // Đổi từ score sang totalPoints
  final int rank;

  LeaderboardEntryModel({
    required this.userId,
    required this.username,
    required this.totalPoints,
    required this.rank,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['userId'] as String? ?? '',

      // Xử lý username: Backend có thể lưu trong metadata hoặc bảng user riêng
      // Ở Stats Service, ta đã lưu username vào Leaderboard document
      username: json['username'] as String? ?? 'User',

      // SỬA QUAN TRỌNG: Backend trả về 'totalPoints', không phải 'score'
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,

      // Rank thường được tính toán lúc query hoặc backend trả về index
      rank: (json['rank'] as num?)?.toInt() ?? 0,
    );
  }

  LeaderboardEntryEntity toEntity() {
    return LeaderboardEntryEntity(
      userId: userId,
      username: username,
      totalPoints: totalPoints, // Map totalPoints vào totalPoints của Entity
      rank: rank,
    );
  }
}

/// Achievement Model
class AchievementModel {
  final String id;
  final String userId;
  final String achievementType;
  final DateTime unlockedAt;
  final bool notified;

  AchievementModel({
    required this.id,
    required this.userId,
    required this.achievementType,
    required this.unlockedAt,
    required this.notified,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      achievementType: json['achievementType'] as String? ?? '',
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : DateTime.now(),
      notified: json['notified'] as bool? ?? false,
    );
  }

  AchievementEntity toEntity() {
    return AchievementEntity(
      id: id,
      userId: userId,
      achievementType: achievementType,
      unlockedAt: unlockedAt,
      notified: notified,
    );
  }
}
