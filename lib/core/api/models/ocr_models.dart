// OCR Line Detail từ backend
class OcrLineDetail {
  final String text;
  final double confidence;

  OcrLineDetail({
    required this.text,
    required this.confidence,
  });

  factory OcrLineDetail.fromJson(Map<String, dynamic> json) {
    return OcrLineDetail(
      text: json['text'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

// Vocabulary Card từ LLM
class VocabularyCard {
  final String term;
  final String kanji;
  final String meaning;

  VocabularyCard({
    required this.term,
    required this.kanji,
    required this.meaning,
  });

  factory VocabularyCard.fromJson(Map<String, dynamic> json) {
    return VocabularyCard(
      term: json['term'] ?? '',
      kanji: json['kanji'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }
}

// OCR Response từ backend Python (đã có LLM parsing)
class OcrResponse {
  final String fullText;
  final List<VocabularyCard> cards;
  final List<OcrLineDetail> rawOcrDetails;

  OcrResponse({
    required this.fullText,
    required this.cards,
    required this.rawOcrDetails,
  });

  factory OcrResponse.fromJson(Map<String, dynamic> json) {
    return OcrResponse(
      fullText: json['full_text'] ?? '',
      cards: (json['cards'] as List? ?? [])
          .map((card) => VocabularyCard.fromJson(card as Map<String, dynamic>))
          .toList(),
      rawOcrDetails: (json['raw_ocr_details'] as List? ?? [])
          .map((line) => OcrLineDetail.fromJson(line as Map<String, dynamic>))
          .toList(),
    );
  }
}
