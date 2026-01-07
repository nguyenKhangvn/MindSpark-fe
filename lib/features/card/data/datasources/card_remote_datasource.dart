import '../../../../core/network/dio_api_client.dart';
import '../models/card_model.dart';
import '../models/card_summary_model.dart';

// Response wrapper cho getCards
class CardsWithSummaryResponse {
  final List<CardModel> cards;
  final CardSummaryModel summary;

  CardsWithSummaryResponse({required this.cards, required this.summary});
}

abstract class CardRemoteDataSource {
  Future<CardsWithSummaryResponse> getCards(String deckId);
  Future<CardModel> createCard({
    required String deckId,
    required String front,
    required String back,
    String? kanji, // Th\u00eam kanji parameter
  });
  Future<List<CardModel>> createCards(List<Map<String, dynamic>> cards);
  Future<CardModel> updateCard({
    required String cardId,
    String? front,
    String? back,
    String? kanji,
  });
  Future<void> deleteCard(String cardId);
}

class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  final DioApiClient apiClient;

  CardRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CardsWithSummaryResponse> getCards(String deckId) async {
    final response =
        await apiClient.get('/cards', queryParameters: {'deckId': deckId});

    // Backend mới trả về {summary: {...}, data: [...]}
    final responseData = response.data as Map<String, dynamic>;
    final List<dynamic> cardsData = responseData['data'] as List<dynamic>;
    final summaryData = responseData['summary'] as Map<String, dynamic>;

    final cards = cardsData
        .map((json) => CardModel.fromJson(json as Map<String, dynamic>))
        .toList();

    final summary = CardSummaryModel.fromJson(summaryData);

    return CardsWithSummaryResponse(cards: cards, summary: summary);
  }

  @override
  Future<CardModel> createCard({
    required String deckId,
    required String front,
    required String back,
    String? kanji,
  }) async {
    final data = {
      'deckId': deckId,
      'front': front,
      'back': back,
    };

    // Ch\u1ec9 th\u00eam kanji n\u1ebfu c\u00f3 gi\u00e1 tr\u1ecb
    if (kanji != null && kanji.isNotEmpty) {
      data['kanji'] = kanji;
    }

    final response = await apiClient.post('/cards', data: data);
    return CardModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<CardModel>> createCards(List<Map<String, dynamic>> cards) async {
    final response =
        await apiClient.post('/cards/bulk', data: {'cards': cards});

    // 1. Kiểm tra dữ liệu thực tế từ Backend
    final dynamic responseData = response.data;

    // 2. Nếu Backend trả về Map (chứa message và count)
    if (responseData is Map && responseData.containsKey('count')) {
      // Vì Cubit đang đợi một List<CardModel>, chúng ta trả về List rỗng
      // để Cubit phát ra state CardsCreated([]) mà không bị crash
      return [];
    }

    // 3. Nếu sau này Backend trả về danh sách Card thật (List)
    if (responseData is List) {
      return responseData
          .map((json) => CardModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<CardModel> updateCard({
    required String cardId,
    String? front,
    String? back,
    String? kanji,
  }) async {
    final data = <String, dynamic>{};

    if (front != null) data['front'] = front;
    if (back != null) data['back'] = back;
    if (kanji != null) {
      data['kanji'] = kanji.isEmpty ? null : kanji;
    }

    final response = await apiClient.put('/cards/$cardId', data: data);
    return CardModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await apiClient.delete('/cards/$cardId');
  }
}
