import 'package:dartz/dartz.dart';
import '../entities/deck_entity.dart';

/// Deck Repository Interface - Domain layer
abstract class DeckRepository {
  Future<Either<String, List<DeckEntity>>> getDecks();

  Future<Either<String, DeckEntity>> createDeck({
    required String name,
    required String description,
  });

  Future<Either<String, DeckEntity>> updateDeck({
    required String id,
    required String name,
    required String description,
  });

  Future<Either<String, void>> deleteDeck(String id);
}
