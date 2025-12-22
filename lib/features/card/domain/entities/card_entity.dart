import 'package:equatable/equatable.dart';

/// Card Entity - Domain layer
class CardEntity extends Equatable {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? kanji; // Kanji cho tiếng Nhật (optional)
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime? nextReviewDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CardEntity({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.kanji,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
    this.nextReviewDate,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        deckId,
        front,
        back,
        kanji,
        easeFactor,
        interval,
        repetitions,
        nextReviewDate,
        createdAt,
        updatedAt,
      ];
}
