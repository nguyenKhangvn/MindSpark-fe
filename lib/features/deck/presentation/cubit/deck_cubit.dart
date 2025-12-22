import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/deck_usecases.dart';
import 'deck_state.dart';

class DeckCubit extends Cubit<DeckState> {
  final GetDecksUseCase getDecksUseCase;
  final CreateDeckUseCase createDeckUseCase;
  final UpdateDeckUseCase updateDeckUseCase;
  final DeleteDeckUseCase deleteDeckUseCase;

  DeckCubit({
    required this.getDecksUseCase,
    required this.createDeckUseCase,
    required this.updateDeckUseCase,
    required this.deleteDeckUseCase,
  }) : super(DeckInitial());

  /// Get all decks
  Future<void> getDecks() async {
    emit(DeckLoading());

    final result = await getDecksUseCase();

    result.fold(
      (error) => emit(DeckError(error)),
      (decks) => emit(DecksLoaded(decks)),
    );
  }

  /// Create new deck
  Future<void> createDeck({
    required String name,
    required String description,
  }) async {
    emit(DeckLoading());

    final result = await createDeckUseCase(
      name: name,
      description: description,
    );

    result.fold(
      (error) => emit(DeckError(error)),
      (deck) => emit(DeckCreated(deck)),
    );
  }

  /// Update deck
  Future<void> updateDeck({
    required String id,
    required String name,
    required String description,
  }) async {
    emit(DeckLoading());

    final result = await updateDeckUseCase(
      id: id,
      name: name,
      description: description,
    );

    result.fold(
      (error) => emit(DeckError(error)),
      (deck) => emit(DeckUpdated(deck)),
    );
  }

  /// Delete deck
  Future<void> deleteDeck(String id) async {
    emit(DeckLoading());

    final result = await deleteDeckUseCase(id);

    result.fold(
      (error) => emit(DeckError(error)),
      (_) => emit(const DeckDeleted('Deck deleted successfully')),
    );
  }
}
