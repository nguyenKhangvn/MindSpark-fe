import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/stats_usecases.dart';
import '../../domain/entities/weekly_progress_entity.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final GetLeaderboardUseCase getLeaderboardUseCase;
  final GetUserStatsUseCase getUserStatsUseCase;
  final GetWeeklyProgressUseCase getWeeklyProgressUseCase;
  final GetActivityHeatmapUseCase getActivityHeatmapUseCase;
  final GetTopDecksUseCase getTopDecksUseCase;
  final GetAchievementsUseCase getAchievementsUseCase;

  StatsCubit({
    required this.getLeaderboardUseCase,
    required this.getUserStatsUseCase,
    required this.getWeeklyProgressUseCase,
    required this.getActivityHeatmapUseCase,
    required this.getTopDecksUseCase,
    required this.getAchievementsUseCase,
  }) : super(StatsInitial());

  Future<void> getLeaderboard() async {
    emit(StatsLoading());
    final result = await getLeaderboardUseCase();
    result.fold(
      (error) => emit(StatsError(error)),
      (leaderboard) => emit(LeaderboardLoaded(leaderboard)),
    );
  }

  Future<void> getUserStats() async {
    emit(StatsLoading());
    final result = await getUserStatsUseCase();
    result.fold(
      (error) => emit(StatsError(error)),
      (stats) => emit(UserStatsLoaded(stats)),
    );
  }

  /// Load everything needed for the Statistics UI in one state
  Future<void> loadOverview(
      {int heatmapDays = 90, int topDeckLimit = 5}) async {
    emit(StatsLoading());

    // Start all requests concurrently, then await results with correct types.
    final userStatsFuture = getUserStatsUseCase();
    final weeklyFuture = getWeeklyProgressUseCase();
    final heatmapFuture = getActivityHeatmapUseCase(heatmapDays);
    final topDecksFuture = getTopDecksUseCase(topDeckLimit);

    final userStatsResult = await userStatsFuture;
    final weeklyResult = await weeklyFuture;
    final heatmapResult = await heatmapFuture;
    final topDecksResult = await topDecksFuture;

    if (userStatsResult.isLeft()) {
      userStatsResult.fold((error) => emit(StatsError(error)), (_) {});
      return;
    }
    if (weeklyResult.isLeft()) {
      weeklyResult.fold((error) => emit(StatsError(error)), (_) {});
      return;
    }
    if (heatmapResult.isLeft()) {
      heatmapResult.fold((error) => emit(StatsError(error)), (_) {});
      return;
    }
    if (topDecksResult.isLeft()) {
      topDecksResult.fold((error) => emit(StatsError(error)), (_) {});
      return;
    }

    emit(StatsOverviewLoaded(
      stats: userStatsResult.getOrElse(() => throw StateError('No stats')),
      weeklyProgress:
          weeklyResult.getOrElse(() => const <WeeklyProgressEntity>[]),
      activityHeatmap:
          heatmapResult.getOrElse(() => const <ActivityHeatmapEntity>[]),
      topDecks: topDecksResult.getOrElse(() => const <TopDeckEntity>[]),
    ));
  }

  Future<void> loadAnalytics() async {
    emit(StatsLoading());

    // Gọi song song 3 API
    final weeklyResult = await getWeeklyProgressUseCase();
    final heatmapResult = await getActivityHeatmapUseCase(90);
    final topDecksResult = await getTopDecksUseCase(5);

    // Kiểm tra nếu có lỗi
    if (weeklyResult.isLeft()) {
      weeklyResult.fold((error) => emit(StatsError(error)), (_) {});
      return;
    }
    if (heatmapResult.isLeft()) {
      heatmapResult.fold((error) => emit(StatsError(error)), (_) {});
      return;
    }
    if (topDecksResult.isLeft()) {
      topDecksResult.fold((error) => emit(StatsError(error)), (_) {});
      return;
    }

    // Lấy data từ Either
    final List<WeeklyProgressEntity> weeklyData =
        weeklyResult.getOrElse(() => const <WeeklyProgressEntity>[]);
    final List<ActivityHeatmapEntity> heatmapData =
        heatmapResult.getOrElse(() => const <ActivityHeatmapEntity>[]);
    final List<TopDeckEntity> topDecksData =
        topDecksResult.getOrElse(() => const <TopDeckEntity>[]);

    // Nếu tất cả thành công
    emit(AnalyticsLoaded(
      weeklyProgress: weeklyData,
      activityHeatmap: heatmapData,
      topDecks: topDecksData,
    ));
  }

  /// Get user achievements
  Future<void> getAchievements() async {
    emit(StatsLoading());
    final result = await getAchievementsUseCase();
    result.fold(
      (error) => emit(StatsError(error)),
      (achievements) => emit(AchievementsLoaded(achievements)),
    );
  }
}
