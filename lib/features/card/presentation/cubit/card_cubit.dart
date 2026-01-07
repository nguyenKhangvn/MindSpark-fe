import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/card_usecases.dart';
import '../../data/models/card_summary_model.dart';
import 'card_state.dart';

class CardCubit extends Cubit<CardState> {
  final GetCardsUseCase getCardsUseCase;
  final CreateCardUseCase createCardUseCase;
  final CreateCardsUseCase createCardsUseCase;
  final UpdateCardUseCase updateCardUseCase;
  final DeleteCardUseCase deleteCardUseCase;

  CardCubit({
    required this.getCardsUseCase,
    required this.createCardUseCase,
    required this.createCardsUseCase,
    required this.updateCardUseCase,
    required this.deleteCardUseCase,
  }) : super(CardInitial());

  Future<void> getCards(String deckId) async {
    emit(CardLoading());
    final result = await getCardsUseCase(deckId);
    result.fold(
      (error) => emit(CardError(error)),
      (cardsWithSummary) => emit(CardsLoaded(cardsWithSummary.cards,
          summary: cardsWithSummary.summary)),
    );
  }

  Future<void> createCard({
    required String deckId,
    required String front,
    required String back,
    String? kanji,
  }) async {
    emit(CardLoading());
    final result = await createCardUseCase(
        deckId: deckId, front: front, back: back, kanji: kanji);
    result.fold(
      (error) => emit(CardError(error)),
      (card) => emit(CardCreated(card)),
    );
  }

  Future<void> createCards(Map<String, dynamic> data) async {
    emit(CardLoading());
    final result = await createCardsUseCase(data);
    result.fold(
      (error) => emit(CardError(error)),
      (cards) => emit(CardsCreated(cards)),
    );
  }

  Future<void> updateCard({
    required String cardId,
    String? front,
    String? back,
    String? kanji,
  }) async {
    // Lưu state cũ để rollback nếu lỗi
    final previousState = state;

    // Gọi API
    final result = await updateCardUseCase(
      cardId: cardId,
      front: front,
      back: back,
      kanji: kanji,
    );

    result.fold(
      (error) {
        emit(CardError(error));
      },
      (updatedCard) {
        // Cập nhật card trong danh sách hiện tại
        if (previousState is CardsLoaded) {
          final updatedCards = previousState.cards.map((card) {
            return card.id == updatedCard.id ? updatedCard : card;
          }).toList();
          // Emit CardUpdated với toàn bộ danh sách mới
          emit(CardUpdated(updatedCard, updatedCards, previousState.summary));
        } else {
          emit(CardUpdated(updatedCard, [updatedCard], null));
        }
      },
    );
  }

  Future<void> deleteCard(String cardId) async {
    // Lưu state cũ để rollback nếu lỗi
    final previousState = state;

    // Gọi API
    final result = await deleteCardUseCase(cardId);

    result.fold(
      (error) {
        emit(CardError(error));
      },
      (_) {
        // Xóa card khỏi danh sách hiện tại
        if (previousState is CardsLoaded) {
          final updatedCards =
              previousState.cards.where((card) => card.id != cardId).toList();
          // Cập nhật summary: giảm total xuống 1
          final updatedSummary = previousState.summary != null
              ? CardSummaryModel(
                  total: previousState.summary!.total - 1,
                  newCards: previousState.summary!.newCards,
                  learning: previousState.summary!.learning,
                  review: previousState.summary!.review,
                )
              : null;
          // Emit CardDeleted với toàn bộ danh sách mới
          emit(CardDeleted(cardId, updatedCards, updatedSummary));
        } else {
          emit(CardDeleted(cardId, [], null));
        }
      },
    );
  }
}
