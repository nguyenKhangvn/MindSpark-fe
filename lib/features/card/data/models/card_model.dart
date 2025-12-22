import '../../domain/entities/card_entity.dart';

/// Card Model - Data layer
/// Example response from GET /cards:
/// [
///   {
///     "id": "card-123",
///     "deckId": "deck-456",
///     "front": "Hello",
///     "back": "Hola",
///     "easeFactor": 2500,
///     "interval": 0,
///     "repetitions": 0,
///     "nextReviewDate": null,
///     "createdAt": "2024-01-15T10:30:00.000Z",
///     "updatedAt": "2024-01-15T10:30:00.000Z"
///   }
/// ]
class CardModel {
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

  CardModel({
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

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      // 1. Dùng toString() và ?? để đảm bảo luôn có chuỗi, không bao giờ crash
      id: json['id']?.toString() ?? '',
      deckId: json['deckId']?.toString() ?? '',
      front: json['front']?.toString() ?? '',
      back: json['back']?.toString() ?? '',
      kanji: json['kanji']?.toString(), // Optional field, có thể null

      // 2. Ép kiểu num? trước khi toDouble() cho các trường số
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: (json['interval'] as num?)?.toInt() ?? 0,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,

      // 3. Xử lý ngày tháng an toàn (Lưu ý: BE của bạn dùng nextReviewTime)
      nextReviewDate: json['nextReviewTime'] != null
          ? DateTime.tryParse(json['nextReviewTime'].toString())
          : null,

      // 4. Các trường ngày tạo/cập nhật không nên dùng ép kiểu trực tiếp 'as String'
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CardEntity toEntity() {
    return CardEntity(
      id: id,
      deckId: deckId,
      front: front,
      back: back,
      kanji: kanji,
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      nextReviewDate: nextReviewDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
