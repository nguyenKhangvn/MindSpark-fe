import 'package:equatable/equatable.dart';
import '../../domain/entities/study_entity.dart';

abstract class StudyState extends Equatable {
  const StudyState();
  @override
  List<Object?> get props => [];
}

class StudyInitial extends StudyState {}

class StudyLoading extends StudyState {}

class DueCardsLoaded extends StudyState {
  final List<StudyEntity> dueCards;
  const DueCardsLoaded(this.dueCards);
  @override
  List<Object?> get props => [dueCards];
}

class CardReviewed extends StudyState {
  final ReviewResultEntity result;
  const CardReviewed(this.result);
  @override
  List<Object?> get props => [result];
}

class StudyError extends StudyState {
  final String message;
  const StudyError(this.message);
  @override
  List<Object?> get props => [message];
}
