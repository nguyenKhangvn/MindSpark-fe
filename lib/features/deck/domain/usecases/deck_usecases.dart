import 'package:dartz/dartz.dart';
import '../entities/deck_entity.dart';
import '../repositories/deck_repository.dart';

/// Get Decks UseCase
class GetDecksUseCase {
  final DeckRepository repository;

  GetDecksUseCase(this.repository);

  Future<Either<String, List<DeckEntity>>> call() {
    return repository.getDecks();
  }
}

/// Create Deck UseCase
class CreateDeckUseCase {
  final DeckRepository repository;

  CreateDeckUseCase(this.repository);

  Future<Either<String, DeckEntity>> call({
    required String name,
    required String description,
  }) {
    return repository.createDeck(name: name, description: description);
  }
}

/// Update Deck UseCase
class UpdateDeckUseCase {
  final DeckRepository repository;

  UpdateDeckUseCase(this.repository);

  Future<Either<String, DeckEntity>> call({
    required String id,
    required String name,
    required String description,
  }) {
    return repository.updateDeck(id: id, name: name, description: description);
  }
}

/// Delete Deck UseCase
class DeleteDeckUseCase {
  final DeckRepository repository;

  DeleteDeckUseCase(this.repository);

  Future<Either<String, void>> call(String id) {
    return repository.deleteDeck(id);
  }
}
