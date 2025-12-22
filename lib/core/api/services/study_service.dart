import '../api_client.dart';
import '../models/study_models.dart';

class StudyService {
  final ApiClient _apiClient;

  StudyService(this._apiClient);

  /// Get due cards for review
  Future<List<DueCard>> getDueCards({String? deckId}) async {
    final response = await _apiClient.get(
      '/study/due',
      queryParams: deckId != null ? {'deckId': deckId} : null,
    );

    final data = _apiClient.handleResponse(response);
    return (data as List).map((json) => DueCard.fromJson(json)).toList();
  }

  /// Submit card review
  Future<ReviewResult> reviewCard({
    required String cardId,
    required int quality, // 0-5 (0=total blackout, 5=perfect response)
  }) async {
    final response = await _apiClient.post(
      '/study/review/$cardId',
      body: {
        'quality': quality,
      },
    );

    final data = _apiClient.handleResponse(response);
    return ReviewResult.fromJson(data);
  }

  /// Get study statistics for a deck
  Future<StudyStats> getStudyStats(String deckId) async {
    final response = await _apiClient.get('/study/stats/$deckId');
    final data = _apiClient.handleResponse(response);

    return StudyStats.fromJson(data);
  }

  /// Get all study statistics (all decks)
  Future<List<StudyStats>> getAllStudyStats() async {
    final response = await _apiClient.get('/study/stats');
    final data = _apiClient.handleResponse(response);

    return (data as List).map((json) => StudyStats.fromJson(json)).toList();
  }
}
