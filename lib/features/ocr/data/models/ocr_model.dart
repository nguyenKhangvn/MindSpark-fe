import '../../domain/entities/ocr_entity.dart';

/// OCR Line Detail Model
class OcrLineDetailModel extends OcrLineDetailEntity {
  const OcrLineDetailModel({
    required super.text,
    required super.confidence,
  });

  factory OcrLineDetailModel.fromJson(Map<String, dynamic> json) {
    return OcrLineDetailModel(
      text: json['text'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'confidence': confidence,
    };
  }
}

/// Vocabulary Card Model
class VocabularyCardModel extends VocabularyCardEntity {
  const VocabularyCardModel({
    required super.term,
    required super.kanji,
    required super.meaning,
  });

  factory VocabularyCardModel.fromJson(Map<String, dynamic> json) {
    return VocabularyCardModel(
      term: json['term'] ?? '',
      kanji: json['kanji'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'kanji': kanji,
      'meaning': meaning,
    };
  }
}

/// OCR Response Model
class OcrResponseModel extends OcrResponseEntity {
  const OcrResponseModel({
    required super.fullText,
    required super.cards,
    required super.rawOcrDetails,
  });

  factory OcrResponseModel.fromJson(Map<String, dynamic> json) {
    return OcrResponseModel(
      fullText: json['full_text'] ?? '',
      cards: (json['cards'] as List? ?? [])
          .map((card) =>
              VocabularyCardModel.fromJson(card as Map<String, dynamic>))
          .toList(),
      rawOcrDetails: (json['raw_ocr_details'] as List? ?? [])
          .map((line) =>
              OcrLineDetailModel.fromJson(line as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_text': fullText,
      'cards': cards.map((card) {
        final cardModel = card as VocabularyCardModel;
        return cardModel.toJson();
      }).toList(),
      'raw_ocr_details': rawOcrDetails.map((line) {
        final lineModel = line as OcrLineDetailModel;
        return lineModel.toJson();
      }).toList(),
    };
  }

  OcrResponseEntity toEntity() {
    return OcrResponseEntity(
      fullText: fullText,
      cards: cards,
      rawOcrDetails: rawOcrDetails,
    );
  }
}
