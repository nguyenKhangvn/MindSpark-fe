import 'package:equatable/equatable.dart';

class WeeklyProgressEntity extends Equatable {
  final String date; // ISO date string (YYYY-MM-DD)
  final int cardsStudied;
  final int studyTimeMinutes;
  final double accuracy;

  const WeeklyProgressEntity({
    required this.date,
    required this.cardsStudied,
    required this.studyTimeMinutes,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [date, cardsStudied, studyTimeMinutes, accuracy];
}

class ActivityHeatmapEntity extends Equatable {
  final String date; // ISO date string (YYYY-MM-DD)
  final int count;
  final int intensity; // 0-4 scale

  const ActivityHeatmapEntity({
    required this.date,
    required this.count,
    required this.intensity,
  });

  @override
  List<Object?> get props => [date, count, intensity];
}

class TopDeckEntity extends Equatable {
  final String deckId;
  final String deckName;
  final int cardsStudied;
  final int correctAnswers;
  final int wrongAnswers;
  final double accuracy;
  final int studyTimeMinutes;

  const TopDeckEntity({
    required this.deckId,
    required this.deckName,
    required this.cardsStudied,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.accuracy,
    required this.studyTimeMinutes,
  });

  @override
  List<Object?> get props => [
        deckId,
        deckName,
        cardsStudied,
        correctAnswers,
        wrongAnswers,
        accuracy,
        studyTimeMinutes,
      ];
}
