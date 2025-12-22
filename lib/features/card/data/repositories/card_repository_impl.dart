import 'package:dartz/dartz.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_remote_datasource.dart';
import '../models/card_summary_model.dart';

// Response wrapper
class CardsWithSummary {
  final List<CardEntity> cards;
  final CardSummaryModel summary;

  CardsWithSummary({required this.cards, required this.summary});
}

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource remoteDataSource;

  CardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, CardsWithSummary>> getCards(String deckId) async {
    try {
      final response = await remoteDataSource.getCards(deckId);
      final cards = response.cards.map((model) => model.toEntity()).toList();
      return Right(CardsWithSummary(cards: cards, summary: response.summary));
    } catch (e) {
      return Left('Lấy danh sách thẻ thất bại: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, CardEntity>> createCard({
    required String deckId,
    required String front,
    required String back,
    String? kanji,
  }) async {
    try {
      final card = await remoteDataSource.createCard(
        deckId: deckId,
        front: front,
        back: back,
        kanji: kanji,
      );
      return Right(card.toEntity());
    } catch (e) {
      return Left('Tạo thẻ đơn lẻ thất bại: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<CardEntity>>> createCards(
      Map<String, dynamic> data) async {
    try {
      // Gọi RemoteDataSource để gửi request lên Gateway (3000)
      final cardModels = await remoteDataSource.createCards([data]);

      // Chuyển đổi List<CardModel> thành List<CardEntity>
      final entities = cardModels.map((model) => model.toEntity()).toList();

      return Right(entities);
    } catch (e) {
      return Left('Lỗi lưu thẻ hàng loạt: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, CardEntity>> updateCard({
    required String cardId,
    String? front,
    String? back,
    String? kanji,
  }) async {
    try {
      final card = await remoteDataSource.updateCard(
        cardId: cardId,
        front: front,
        back: back,
        kanji: kanji,
      );
      return Right(card.toEntity());
    } catch (e) {
      return Left('Cập nhật thẻ thất bại: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteCard(String cardId) async {
    try {
      await remoteDataSource.deleteCard(cardId);
      return const Right(null);
    } catch (e) {
      return Left('Xóa thẻ thất bại: ${e.toString()}');
    }
  }
}
