import '../models/deck_models.dart';
import '../../network/dio_client_with_interceptor.dart';

/// Deck service using Dio with automatic token refresh
/// Migration example from old ApiClient to new DioClientWithInterceptor
class DeckServiceDio {
  final DioClientWithInterceptor _dioClient;

  DeckServiceDio(this._dioClient);

  /// Get all decks for current user
  /// Old: await _apiClient.get('/decks')
  /// New: await _dioClient.dio.get('/decks')
  Future<List<Deck>> getDecks() async {
    final response = await _dioClient.dio.get('/decks');

    return (response.data as List).map((json) => Deck.fromJson(json)).toList();
  }

  /// Get single deck by ID
  Future<Deck> getDeck(String id) async {
    final response = await _dioClient.dio.get('/decks/$id');
    return Deck.fromJson(response.data);
  }

  /// Create new deck
  Future<Deck> createDeck({
    required String name,
    String? description,
    String? languageCode,
  }) async {
    final response = await _dioClient.dio.post(
      '/decks',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (languageCode != null) 'languageCode': languageCode,
      },
    );

    return Deck.fromJson(response.data);
  }

  /// Update deck
  Future<Deck> updateDeck({
    required String id,
    String? name,
    String? description,
  }) async {
    final response = await _dioClient.dio.put(
      '/decks/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      },
    );

    return Deck.fromJson(response.data);
  }

  /// Delete deck
  Future<void> deleteDeck(String id) async {
    await _dioClient.dio.delete('/decks/$id');
  }

  /// Get deck statistics
  Future<Map<String, dynamic>> getDeckStats(String id) async {
    final response = await _dioClient.dio.get('/decks/$id/stats');
    return response.data;
  }
}
