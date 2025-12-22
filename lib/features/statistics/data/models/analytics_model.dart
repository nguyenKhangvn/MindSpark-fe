import '../../domain/entities/weekly_progress_entity.dart';

class WeeklyProgressModel {
  final String date;
  final int cardsStudied;
  final int studyTimeMinutes;
  final double accuracy;

  WeeklyProgressModel({
    required this.date,
    required this.cardsStudied,
    required this.studyTimeMinutes,
    required this.accuracy,
  });

  factory WeeklyProgressModel.fromJson(Map<String, dynamic> json) {
    return WeeklyProgressModel(
      date: json['date'] as String,
      cardsStudied: json['cardsStudied'] as int,
      studyTimeMinutes: json['studyTimeMinutes'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
    );
  }

  WeeklyProgressEntity toEntity() {
    return WeeklyProgressEntity(
      date: date,
      cardsStudied: cardsStudied,
      studyTimeMinutes: studyTimeMinutes,
      accuracy: accuracy,
    );
  }
}

class ActivityHeatmapModel {
  final String date;
  final int count;
  final int intensity;

  ActivityHeatmapModel({
    required this.date,
    required this.count,
    required this.intensity,
  });

  factory ActivityHeatmapModel.fromJson(Map<String, dynamic> json) {
    return ActivityHeatmapModel(
      date: json['date'] as String,
      count: json['count'] as int,
      intensity: json['intensity'] as int,
    );
  }

  ActivityHeatmapEntity toEntity() {
    return ActivityHeatmapEntity(
      date: date,
      count: count,
      intensity: intensity,
    );
  }
}

class TopDeckModel {
  final String deckId;
  final String deckName;
  final int cardsStudied;
  final int correctAnswers;
  final int wrongAnswers;
  final double accuracy;
  final int studyTimeMinutes;

  TopDeckModel({
    required this.deckId,
    required this.deckName,
    required this.cardsStudied,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.accuracy,
    required this.studyTimeMinutes,
  });

  factory TopDeckModel.fromJson(Map<String, dynamic> json) {
    return TopDeckModel(
      deckId: json['deckId'] as String,
      deckName: json['deckName'] as String,
      cardsStudied: json['cardsStudied'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      studyTimeMinutes: json['studyTimeMinutes'] as int,
    );
  }

  TopDeckEntity toEntity() {
    return TopDeckEntity(
      deckId: deckId,
      deckName: deckName,
      cardsStudied: cardsStudied,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      accuracy: accuracy,
      studyTimeMinutes: studyTimeMinutes,
    );
  }
}
