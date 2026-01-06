import 'package:equatable/equatable.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/entities/weekly_progress_entity.dart';

abstract class StatsState extends Equatable {
  const StatsState();
  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class LeaderboardLoaded extends StatsState {
  final List<LeaderboardEntryEntity> leaderboard;
  const LeaderboardLoaded(this.leaderboard);
  @override
  List<Object?> get props => [leaderboard];
}

class UserStatsLoaded extends StatsState {
  final UserStatsEntity stats;
  const UserStatsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class StatsOverviewLoaded extends StatsState {
  final UserStatsEntity stats;
  final List<WeeklyProgressEntity> weeklyProgress;
  final List<ActivityHeatmapEntity> activityHeatmap;
  final List<TopDeckEntity> topDecks;

  const StatsOverviewLoaded({
    required this.stats,
    required this.weeklyProgress,
    required this.activityHeatmap,
    required this.topDecks,
  });

  @override
  List<Object?> get props => [stats, weeklyProgress, activityHeatmap, topDecks];
}

class AnalyticsLoaded extends StatsState {
  final List<WeeklyProgressEntity> weeklyProgress;
  final List<ActivityHeatmapEntity> activityHeatmap;
  final List<TopDeckEntity> topDecks;

  const AnalyticsLoaded({
    required this.weeklyProgress,
    required this.activityHeatmap,
    required this.topDecks,
  });

  @override
  List<Object?> get props => [weeklyProgress, activityHeatmap, topDecks];
}

class AchievementsLoaded extends StatsState {
  final List<AchievementEntity> achievements;
  const AchievementsLoaded(this.achievements);
  @override
  List<Object?> get props => [achievements];
}

class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);
  @override
  List<Object?> get props => [message];
}
