import 'package:equatable/equatable.dart';

/// OCR Line Detail Entity
class OcrLineDetailEntity extends Equatable {
  final String text;
  final double confidence;

  const OcrLineDetailEntity({
    required this.text,
    required this.confidence,
  });

  @override
  List<Object?> get props => [text, confidence];
}

/// Vocabulary Card Entity
class VocabularyCardEntity extends Equatable {
  final String term;
  final String kanji;
  final String meaning;

  const VocabularyCardEntity({
    required this.term,
    required this.kanji,
    required this.meaning,
  });

  @override
  List<Object?> get props => [term, kanji, meaning];
}

/// OCR Response Entity
class OcrResponseEntity extends Equatable {
  final String fullText;
  final List<VocabularyCardEntity> cards;
  final List<OcrLineDetailEntity> rawOcrDetails;

  const OcrResponseEntity({
    required this.fullText,
    required this.cards,
    required this.rawOcrDetails,
  });

  @override
  List<Object?> get props => [fullText, cards, rawOcrDetails];
}
