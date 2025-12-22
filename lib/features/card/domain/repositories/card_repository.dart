import 'package:dartz/dartz.dart';
import '../entities/card_entity.dart';
import '../../data/repositories/card_repository_impl.dart'; // Import CardsWithSummary

abstract class CardRepository {
  Future<Either<String, CardsWithSummary>> getCards(String deckId);
  Future<Either<String, CardEntity>> createCard({
    required String deckId,
    required String front,
    required String back,
    String? kanji,
  });
  Future<Either<String, List<CardEntity>>> createCards(
      Map<String, dynamic> data);
  Future<Either<String, CardEntity>> updateCard({
    required String cardId,
    String? front,
    String? back,
    String? kanji,
  });
  Future<Either<String, void>> deleteCard(String cardId);
}
