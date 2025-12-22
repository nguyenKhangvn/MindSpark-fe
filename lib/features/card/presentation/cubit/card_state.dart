import 'package:equatable/equatable.dart';
import '../../domain/entities/card_entity.dart';
import '../../data/models/card_summary_model.dart';

abstract class CardState extends Equatable {
  const CardState();
  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardsLoaded extends CardState {
  final List<CardEntity> cards;
  final CardSummaryModel? summary; // Thêm summary

  const CardsLoaded(this.cards, {this.summary});

  @override
  List<Object?> get props => [cards, summary];
}

class CardCreated extends CardState {
  final CardEntity card;
  const CardCreated(this.card);
  @override
  List<Object?> get props => [card];
}

class CardsCreated extends CardState {
  final List<CardEntity> cards;
  const CardsCreated(this.cards);
  @override
  List<Object?> get props => [cards];
}

class CardUpdated extends CardState {
  final CardEntity card; // Card vừa được update
  final List<CardEntity> allCards; // Toàn bộ danh sách cards sau khi update
  final CardSummaryModel? summary;
  
  const CardUpdated(this.card, this.allCards, this.summary);
  
  @override
  List<Object?> get props => [card, allCards, summary];
}

class CardDeleted extends CardState {
  final String cardId; // Card ID vừa bị xóa
  final List<CardEntity> remainingCards; // Danh sách cards còn lại
  final CardSummaryModel? summary;
  
  const CardDeleted(this.cardId, this.remainingCards, this.summary);
  
  @override
  List<Object?> get props => [cardId, remainingCards, summary];
}

class CardError extends CardState {
  final String message;
  const CardError(this.message);
  @override
  List<Object?> get props => [message];
}
