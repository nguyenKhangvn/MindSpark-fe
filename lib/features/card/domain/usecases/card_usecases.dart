import 'package:dartz/dartz.dart';
import '../entities/card_entity.dart';
import '../repositories/card_repository.dart';
import '../../data/repositories/card_repository_impl.dart'; // Import CardsWithSummary

class GetCardsUseCase {
  final CardRepository repository;
  GetCardsUseCase(this.repository);

  Future<Either<String, CardsWithSummary>> call(String deckId) {
    return repository.getCards(deckId);
  }
}

class CreateCardUseCase {
  final CardRepository repository;
  CreateCardUseCase(this.repository);

  Future<Either<String, CardEntity>> call({
    required String deckId,
    required String front,
    required String back,
    String? kanji,
  }) {
    return repository.createCard(deckId: deckId, front: front, back: back, kanji: kanji);
  }
}

class CreateCardsUseCase {
  final CardRepository repository;
  CreateCardsUseCase(this.repository);

  Future<Either<String, List<CardEntity>>> call(
      Map<String, dynamic> params) async {
    return await repository.createCards(params);
  }
}

class UpdateCardUseCase {
  final CardRepository repository;
  UpdateCardUseCase(this.repository);

  Future<Either<String, CardEntity>> call({
    required String cardId,
    String? front,
    String? back,
    String? kanji,
  }) {
    return repository.updateCard(
      cardId: cardId,
      front: front,
      back: back,
      kanji: kanji,
    );
  }
}

class DeleteCardUseCase {
  final CardRepository repository;
  DeleteCardUseCase(this.repository);

  Future<Either<String, void>> call(String cardId) {
    return repository.deleteCard(cardId);
  }
}
