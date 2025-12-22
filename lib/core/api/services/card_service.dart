import '../api_client.dart';
import '../models/card_models.dart';

class CardService {
  final ApiClient _apiClient;

  CardService(this._apiClient);

  /// Get all cards in a deck
  Future<List<FlashCard>> getCards(String deckId) async {
    final response = await _apiClient.get(
      '/cards',
      queryParams: {'deckId': deckId},
    );

    final data = _apiClient.handleResponse(response);
    return (data as List).map((json) => FlashCard.fromJson(json)).toList();
  }

  /// Get a single card by ID
  Future<FlashCard> getCard(String cardId) async {
    final response = await _apiClient.get('/cards/$cardId');
    final data = _apiClient.handleResponse(response);

    return FlashCard.fromJson(data);
  }

  /// Create a new card
  Future<FlashCard> createCard({
    required String deckId,
    required String front,
    required String back,
    String? kanji,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final response = await _apiClient.post(
      '/cards',
      body: {
        'deckId': deckId,
        'front': front,
        'back': back,
        if (kanji != null) 'kanji': kanji,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (audioUrl != null) 'audioUrl': audioUrl,
      },
    );

    final data = _apiClient.handleResponse(response);
    return FlashCard.fromJson(data);
  }

  /// Create multiple cards (bulk import)
  Future<List<FlashCard>> createCards({
    required String deckId,
    required List<Map<String, dynamic>> cards,
  }) async {
    final response = await _apiClient.post(
      '/cards/bulk',
      body: {
        'deckId': deckId,
        'cards': cards,
      },
    );

    final data = _apiClient.handleResponse(response);
    return (data as List).map((json) => FlashCard.fromJson(json)).toList();
  }

  /// Update a card
  Future<FlashCard> updateCard({
    required String cardId,
    String? front,
    String? back,
    String? kanji,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final body = <String, dynamic>{};
    if (front != null) body['front'] = front;
    if (back != null) body['back'] = back;
    if (kanji != null) body['kanji'] = kanji;
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (audioUrl != null) body['audioUrl'] = audioUrl;

    final response = await _apiClient.put(
      '/cards/$cardId',
      body: body,
    );

    final data = _apiClient.handleResponse(response);
    return FlashCard.fromJson(data);
  }

  /// Delete a card
  Future<void> deleteCard(String cardId) async {
    final response = await _apiClient.delete('/cards/$cardId');
    _apiClient.handleResponse(response);
  }

  /// Upload image for OCR processing
  Future<OcrResult> uploadImageForOcr(String filePath) async {
    // Note: This requires multipart form data
    // Implementation depends on your file upload setup
    throw UnimplementedError('Image upload requires multipart implementation');
  }
}
