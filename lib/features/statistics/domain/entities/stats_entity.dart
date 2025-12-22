import 'package:equatable/equatable.dart';

class UserStatsEntity extends Equatable {
  final String userId;
  final int totalCards;
  final int cardsReviewed;
  final int streak;
  final double accuracy;

  const UserStatsEntity({
    required this.userId,
    required this.totalCards,
    required this.cardsReviewed,
    required this.streak,
    required this.accuracy,
  });

  @override
  List<Object?> get props =>
      [userId, totalCards, cardsReviewed, streak, accuracy];
}

class LeaderboardEntryEntity extends Equatable {
  final String userId;
  final String username;
  final int score;
  final int rank;

  const LeaderboardEntryEntity({
    required this.userId,
    required this.username,
    required this.score,
    required this.rank,
  });

  @override
  List<Object?> get props => [userId, username, score, rank];
}
