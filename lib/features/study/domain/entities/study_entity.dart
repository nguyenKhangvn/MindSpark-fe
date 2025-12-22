import 'package:equatable/equatable.dart';
import '../../../card/domain/entities/card_entity.dart';

class StudyEntity extends Equatable {
  final CardEntity card;
  final DateTime? nextReviewTime;

  const StudyEntity({
    required this.card,
    required this.nextReviewTime,
  });

  @override
  List<Object?> get props => [card, nextReviewTime];
}

class ReviewResultEntity extends Equatable {
  final CardEntity card;
  final DateTime nextReview;
  final String? message;

  const ReviewResultEntity({
    required this.card,
    required this.nextReview,
    this.message,
  });

  @override
  List<Object?> get props => [card, nextReview, message];
}
