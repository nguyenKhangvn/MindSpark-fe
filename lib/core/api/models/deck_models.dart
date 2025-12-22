class Deck {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String language;
  final String? imageUrl;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int cardCount;

  Deck({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.language,
    this.imageUrl,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.cardCount = 0,
  });

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      language: json['language'] as String,
      imageUrl: json['imageUrl'] as String?,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cardCount: (json['_count']?['cards'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'language': language,
      'imageUrl': imageUrl,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class DeckStats {
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int masteredCards;
  final double averageEaseFactor;
  final int totalReviews;

  DeckStats({
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.masteredCards,
    required this.averageEaseFactor,
    required this.totalReviews,
  });

  factory DeckStats.fromJson(Map<String, dynamic> json) {
    return DeckStats(
      totalCards: json['totalCards'] as int,
      newCards: json['newCards'] as int,
      learningCards: json['learningCards'] as int,
      reviewCards: json['reviewCards'] as int,
      masteredCards: json['masteredCards'] as int,
      averageEaseFactor: (json['averageEaseFactor'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCards': totalCards,
      'newCards': newCards,
      'learningCards': learningCards,
      'reviewCards': reviewCards,
      'masteredCards': masteredCards,
      'averageEaseFactor': averageEaseFactor,
      'totalReviews': totalReviews,
    };
  }
}
