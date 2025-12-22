import 'package:dartz/dartz.dart';
import '../entities/stats_entity.dart';
import '../entities/weekly_progress_entity.dart';

abstract class StatsRepository {
  Future<Either<String, List<LeaderboardEntryEntity>>> getLeaderboard();
  Future<Either<String, UserStatsEntity>> getUserStats();
  Future<Either<String, List<WeeklyProgressEntity>>> getWeeklyProgress();
  Future<Either<String, List<ActivityHeatmapEntity>>> getActivityHeatmap({int days});
  Future<Either<String, List<TopDeckEntity>>> getTopPerformingDecks({int limit});
}
