import '../api_client.dart';
import '../models/stats_models.dart';

class StatsService {
  final ApiClient _apiClient;

  StatsService(this._apiClient);

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 100}) async {
    final response = await _apiClient.get(
      '/stats/leaderboard',
      queryParams: {'limit': limit.toString()},
    );

    final data = _apiClient.handleResponse(response);
    return (data as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
  }

  /// Get current user statistics (JWT authenticated)
  Future<UserStats> getUserStats() async {
    final response = await _apiClient.get('/stats/me');
    final data = _apiClient.handleResponse(response);

    return UserStats.fromJson(data);
  }

  /// Get current user achievements (JWT authenticated)
  Future<List<Achievement>> getUserAchievements() async {
    final response = await _apiClient.get('/stats/me/achievements');
    final data = _apiClient.handleResponse(response);

    return (data as List).map((json) => Achievement.fromJson(json)).toList();
  }

  /// Get current user activity history (JWT authenticated)
  Future<List<Activity>> getUserActivity({int days = 30}) async {
    final response = await _apiClient.get(
      '/stats/me/activity',
      queryParams: {'days': days.toString()},
    );

    final data = _apiClient.handleResponse(response);
    return (data as List).map((json) => Activity.fromJson(json)).toList();
  }

  /// Get current user daily statistics (JWT authenticated)
  Future<List<DailyStats>> getDailyStats({int days = 30}) async {
    final response = await _apiClient.get(
      '/stats/me/daily-stats',
      queryParams: {'days': days.toString()},
    );

    final data = _apiClient.handleResponse(response);
    return (data as List).map((json) => DailyStats.fromJson(json)).toList();
  }
}
