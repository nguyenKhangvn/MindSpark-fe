import 'package:dartz/dartz.dart';
import '../entities/stats_entity.dart';
import '../entities/weekly_progress_entity.dart';
import '../repositories/stats_repository.dart';

class GetLeaderboardUseCase {
  final StatsRepository repository;
  GetLeaderboardUseCase(this.repository);

  Future<Either<String, List<LeaderboardEntryEntity>>> call() {
    return repository.getLeaderboard();
  }
}

class GetUserStatsUseCase {
  final StatsRepository repository;
  GetUserStatsUseCase(this.repository);

  Future<Either<String, UserStatsEntity>> call() {
    return repository.getUserStats();
  }
}

class GetWeeklyProgressUseCase {
  final StatsRepository repository;
  GetWeeklyProgressUseCase(this.repository);

  Future<Either<String, List<WeeklyProgressEntity>>> call() {
    return repository.getWeeklyProgress();
  }
}

class GetActivityHeatmapUseCase {
  final StatsRepository repository;
  GetActivityHeatmapUseCase(this.repository);

  Future<Either<String, List<ActivityHeatmapEntity>>> call(int days) {
    return repository.getActivityHeatmap(days: days);
  }
}

class GetTopDecksUseCase {
  final StatsRepository repository;
  GetTopDecksUseCase(this.repository);

  Future<Either<String, List<TopDeckEntity>>> call(int limit) {
    return repository.getTopPerformingDecks(limit: limit);
  }
}

class GetAchievementsUseCase {
  final StatsRepository repository;
  GetAchievementsUseCase(this.repository);

  Future<Either<String, List<AchievementEntity>>> call() {
    return repository.getAchievements();
  }
}
