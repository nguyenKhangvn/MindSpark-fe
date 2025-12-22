import 'package:equatable/equatable.dart';
import '../../domain/entities/deck_entity.dart';

abstract class DeckState extends Equatable {
  const DeckState();

  @override
  List<Object?> get props => [];
}

class DeckInitial extends DeckState {}

class DeckLoading extends DeckState {}

class DecksLoaded extends DeckState {
  final List<DeckEntity> decks;

  const DecksLoaded(this.decks);

  @override
  List<Object?> get props => [decks];
}

class DeckCreated extends DeckState {
  final DeckEntity deck;

  const DeckCreated(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckUpdated extends DeckState {
  final DeckEntity deck;

  const DeckUpdated(this.deck);

  @override
  List<Object?> get props => [deck];
}

class DeckDeleted extends DeckState {
  final String message;

  const DeckDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class DeckError extends DeckState {
  final String message;

  const DeckError(this.message);

  @override
  List<Object?> get props => [message];
}
