class FlashCard {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? kanji;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlashCard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.kanji,
    this.imageUrl,
    this.audioUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      kanji: json['kanji'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class OcrResult {
  final String text;
  final List<FlashCard> cards;
  final double confidence;

  OcrResult({
    required this.text,
    required this.cards,
    required this.confidence,
  });

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      text: json['text'] as String,
      cards: (json['cards'] as List)
          .map((card) => FlashCard.fromJson(card as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'cards': cards.map((card) => card.toJson()).toList(),
      'confidence': confidence,
    };
  }
}
