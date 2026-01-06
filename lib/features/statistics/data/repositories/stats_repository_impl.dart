import 'package:dartz/dartz.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/entities/weekly_progress_entity.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_remote_datasource.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDataSource remoteDataSource;

  StatsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<LeaderboardEntryEntity>>> getLeaderboard() async {
    try {
      final entries = await remoteDataSource.getLeaderboard();
      return Right(entries.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left('Stats error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, UserStatsEntity>> getUserStats() async {
    try {
      final stats = await remoteDataSource.getUserStats();
      return Right(stats.toEntity());
    } catch (e) {
      return Left('Stats error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<WeeklyProgressEntity>>> getWeeklyProgress() async {
    try {
      final progress = await remoteDataSource.getWeeklyProgress();
      return Right(progress.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left('Stats error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ActivityHeatmapEntity>>> getActivityHeatmap(
      {int days = 90}) async {
    try {
      final heatmap = await remoteDataSource.getActivityHeatmap(days: days);
      return Right(heatmap.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left('Stats error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<TopDeckEntity>>> getTopPerformingDecks(
      {int limit = 5}) async {
    try {
      final decks = await remoteDataSource.getTopPerformingDecks(limit: limit);
      return Right(decks.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left('Stats error: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<AchievementEntity>>> getAchievements() async {
    try {
      final achievements = await remoteDataSource.getAchievements();
      return Right(achievements.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left('Stats error: ${e.toString()}');
    }
  }
}
