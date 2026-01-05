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
