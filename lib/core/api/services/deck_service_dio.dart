import '../models/deck_models.dart';
import '../../network/dio_api_client.dart';

/// Deck service using Dio with callback-based token refresh
class DeckServiceDio {
  final DioApiClient _dioClient;

  DeckServiceDio(this._dioClient);

  /// Get all decks for current user
  Future<List<Deck>> getDecks() async {
    final response = await _dioClient.get('/decks');

    return (response.data as List).map((json) => Deck.fromJson(json)).toList();
  }

  /// Get single deck by ID
  Future<Deck> getDeck(String id) async {
    final response = await _dioClient.get('/decks/$id');
    return Deck.fromJson(response.data);
  }

  /// Create new deck
  Future<Deck> createDeck({
    required String name,
    String? description,
    String? languageCode,
  }) async {
    final response = await _dioClient.post(
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
    final response = await _dioClient.put(
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
    await _dioClient.delete('/decks/$id');
  }

  /// Get deck statistics
  Future<Map<String, dynamic>> getDeckStats(String id) async {
    final response = await _dioClient.get('/decks/$id/stats');
    return response.data;
  }
}
