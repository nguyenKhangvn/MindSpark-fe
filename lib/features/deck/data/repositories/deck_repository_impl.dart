import 'package:dartz/dartz.dart';
import '../../domain/entities/deck_entity.dart';
import '../../domain/repositories/deck_repository.dart';
import '../datasources/deck_remote_datasource.dart';

class DeckRepositoryImpl implements DeckRepository {
  final DeckRemoteDataSource remoteDataSource;

  DeckRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<DeckEntity>>> getDecks() async {
    try {
      final decks = await remoteDataSource.getDecks();
      return Right(decks.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, DeckEntity>> createDeck({
    required String name,
    required String description,
  }) async {
    try {
      final deck = await remoteDataSource.createDeck(
        name: name,
        description: description,
      );
      return Right(deck.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, DeckEntity>> updateDeck({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      final deck = await remoteDataSource.updateDeck(
        id: id,
        name: name,
        description: description,
      );
      return Right(deck.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteDeck(String id) async {
    try {
      await remoteDataSource.deleteDeck(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  String _handleError(dynamic error) {
    return 'Deck error: ${error.toString()}';
  }
}
