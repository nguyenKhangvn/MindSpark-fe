import '../../../../core/network/dio_api_client.dart';
import '../models/deck_model.dart';

/// Deck Remote DataSource
abstract class DeckRemoteDataSource {
  Future<List<DeckModel>> getDecks();
  Future<DeckModel> createDeck({
    required String name,
    required String description,
  });
  Future<DeckModel> updateDeck({
    required String id,
    required String name,
    required String description,
  });
  Future<void> deleteDeck(String id);
}

class DeckRemoteDataSourceImpl implements DeckRemoteDataSource {
  final DioApiClient apiClient;

  DeckRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<DeckModel>> getDecks() async {
    final response = await apiClient.get('/decks');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => DeckModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DeckModel> createDeck({
    required String name,
    required String description,
  }) async {
    final response = await apiClient.post(
      '/decks',
      data: {
        'name': name,
        'description': description,
      },
    );
    return DeckModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DeckModel> updateDeck({
    required String id,
    required String name,
    required String description,
  }) async {
    final response = await apiClient.put(
      '/decks/$id',
      data: {
        'name': name,
        'description': description,
      },
    );
    return DeckModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteDeck(String id) async {
    await apiClient.delete('/decks/$id');
  }
}
