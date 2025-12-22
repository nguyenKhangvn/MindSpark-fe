import '../api_client.dart';
import '../models/deck_models.dart';

class DeckService {
  final ApiClient _apiClient;

  DeckService(this._apiClient);

  /// Get all decks for current user
  Future<List<Deck>> getDecks() async {
    final response = await _apiClient.get('/decks');
    final data = _apiClient.handleResponse(response);

    return (data as List).map((json) => Deck.fromJson(json)).toList();
  }

  /// Get a single deck by ID
  Future<Deck> getDeck(String deckId) async {
    final response = await _apiClient.get('/decks/$deckId');
    final data = _apiClient.handleResponse(response);

    return Deck.fromJson(data);
  }

  /// Create a new deck
  Future<Deck> createDeck({
    required String name,
    String? description,
    String language = 'en',
    bool isPublic = false,
  }) async {
    final response = await _apiClient.post(
      '/decks',
      body: {
        'name': name,
        'description': description,
        'language': language,
        'isPublic': isPublic,
      },
    );

    final data = _apiClient.handleResponse(response);
    return Deck.fromJson(data);
  }

  /// Update a deck
  Future<Deck> updateDeck({
    required String deckId,
    String? name,
    String? description,
    String? language,
    bool? isPublic,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (language != null) body['language'] = language;
    if (isPublic != null) body['isPublic'] = isPublic;

    final response = await _apiClient.put(
      '/decks/$deckId',
      body: body,
    );

    final data = _apiClient.handleResponse(response);
    return Deck.fromJson(data);
  }

  /// Delete a deck
  Future<void> deleteDeck(String deckId) async {
    final response = await _apiClient.delete('/decks/$deckId');
    _apiClient.handleResponse(response);
  }

  /// Get deck statistics
  Future<DeckStats> getDeckStats(String deckId) async {
    final response = await _apiClient.get('/decks/$deckId/stats');
    final data = _apiClient.handleResponse(response);

    return DeckStats.fromJson(data);
  }
}
