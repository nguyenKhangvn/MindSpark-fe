import '../../../../core/network/dio_api_client.dart';
import '../models/stats_model.dart';
import '../models/analytics_model.dart';

abstract class StatsRemoteDataSource {
  Future<List<LeaderboardEntryModel>> getLeaderboard();
  Future<UserStatsModel> getUserStats();
  Future<List<WeeklyProgressModel>> getWeeklyProgress();
  Future<List<ActivityHeatmapModel>> getActivityHeatmap({int days = 90});
  Future<List<TopDeckModel>> getTopPerformingDecks({int limit = 5});
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  final DioApiClient apiClient;

  StatsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<LeaderboardEntryModel>> getLeaderboard() async {
    final response = await apiClient.get('/stats/leaderboard');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) =>
            LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserStatsModel> getUserStats() async {
    final response = await apiClient.get('/stats/me');
    return UserStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<WeeklyProgressModel>> getWeeklyProgress() async {
    final response = await apiClient.get('/stats/me/weekly-progress');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) =>
            WeeklyProgressModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ActivityHeatmapModel>> getActivityHeatmap({int days = 90}) async {
    final response =
        await apiClient.get('/stats/me/activity-heatmap?days=$days');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) =>
            ActivityHeatmapModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TopDeckModel>> getTopPerformingDecks({int limit = 5}) async {
    final response = await apiClient.get('/stats/me/top-decks?limit=$limit');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => TopDeckModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
