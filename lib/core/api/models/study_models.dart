class DueCard {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? kanji;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime? nextReview;
  final int repetitions;
  final double easeFactor;
  final int interval;

  DueCard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.kanji,
    this.imageUrl,
    this.audioUrl,
    this.nextReview,
    required this.repetitions,
    required this.easeFactor,
    required this.interval,
  });

  factory DueCard.fromJson(Map<String, dynamic> json) {
    return DueCard(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      kanji: json['kanji'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      nextReview: json['nextReviewTime'] != null
          ? DateTime.parse(json['nextReviewTime'] as String)
          : null,
      repetitions: json['repetitions'] as int,
      easeFactor: (json['easeFactor'] as num).toDouble(),
      interval: json['interval'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'front': front,
      'back': back,
      'kanji': kanji,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'nextReview': nextReview?.toIso8601String(),
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'interval': interval,
    };
  }
}

class ReviewResult {
  final String cardId;
  final DateTime nextReview;
  final int repetitions;
  final double easeFactor;
  final int interval;
  final int quality;

  ReviewResult({
    required this.cardId,
    required this.nextReview,
    required this.repetitions,
    required this.easeFactor,
    required this.interval,
    required this.quality,
  });

  factory ReviewResult.fromJson(Map<String, dynamic> json) {
    return ReviewResult(
      cardId: json['cardId'] as String,
      nextReview: DateTime.parse(json['nextReview'] as String),
      repetitions: json['repetitions'] as int,
      easeFactor: (json['easeFactor'] as num).toDouble(),
      interval: json['interval'] as int,
      quality: json['quality'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'nextReview': nextReview.toIso8601String(),
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'interval': interval,
      'quality': quality,
    };
  }
}

class StudyStats {
  final String deckId;
  final int cardsStudied;
  final int cardsRemaining;
  final double averageQuality; // ĐỔI THÀNH: double
  final int totalReviews;
  final int streak;
  final DateTime? lastStudied;

  StudyStats({
    required this.deckId,
    required this.cardsStudied,
    required this.cardsRemaining,
    required this.averageQuality,
    required this.totalReviews,
    required this.streak,
    this.lastStudied,
  });

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    return StudyStats(
      deckId: json['deckId'] as String,
      cardsStudied: json['cardsStudied'] as int,
      cardsRemaining: json['cardsRemaining'] as int,
      averageQuality: (json['averageQuality'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      streak: json['streak'] as int,
      lastStudied: json['lastStudied'] != null
          ? DateTime.parse(json['lastStudied'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'cardsStudied': cardsStudied,
      'cardsRemaining': cardsRemaining,
      'averageQuality': averageQuality,
      'totalReviews': totalReviews,
      'streak': streak,
      'lastStudied': lastStudied?.toIso8601String(),
    };
  }
}
