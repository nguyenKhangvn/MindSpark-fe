/// OCR History Model
/// Represents a pending OCR result saved in backend staging table
class OcrHistoryModel {
  final String id;
  final String userId;
  final String deckId;
  final String? originalText;
  final Map<String, dynamic> resultData; // JSON containing flashcards array
  final String status; // PENDING_REVIEW, COMPLETED, FAILED
  final DateTime createdAt;
  final DateTime updatedAt;

  // Extracted deck info if included in response
  final DeckBasicInfo? deck;

  const OcrHistoryModel({
    required this.id,
    required this.userId,
    required this.deckId,
    this.originalText,
    required this.resultData,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deck,
  });

  factory OcrHistoryModel.fromJson(Map<String, dynamic> json) {
    return OcrHistoryModel(
      id: json['id'],
      userId: json['userId'],
      deckId: json['deckId'],
      originalText: json['originalText'],
      resultData: json['resultData'] as Map<String, dynamic>,
      status: json['status'] ?? 'PENDING_REVIEW',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deck: json['deck'] != null
          ? DeckBasicInfo.fromJson(json['deck'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deckId': deckId,
      'originalText': originalText,
      'resultData': resultData,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deck': deck?.toJson(),
    };
  }

  /// Extract flashcards from resultData
  List<FlashcardData> get flashcards {
    final List<dynamic> cardsJson = resultData['flashcards'] ?? [];
    return cardsJson
        .map((card) => FlashcardData.fromJson(card as Map<String, dynamic>))
        .toList();
  }
}

/// Basic deck information included in OCR history
class DeckBasicInfo {
  final String id;
  final String name;

  const DeckBasicInfo({
    required this.id,
    required this.name,
  });

  factory DeckBasicInfo.fromJson(Map<String, dynamic> json) {
    return DeckBasicInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Flashcard data extracted from OCR result
class FlashcardData {
  final String front;
  final String back;

  const FlashcardData({
    required this.front,
    required this.back,
  });

  factory FlashcardData.fromJson(Map<String, dynamic> json) {
    return FlashcardData(
      front: json['front'] ?? '',
      back: json['back'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'front': front,
      'back': back,
    };
  }
}
