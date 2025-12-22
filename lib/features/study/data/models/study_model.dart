import '../../../card/data/models/card_model.dart';
import '../../domain/entities/study_entity.dart';

class StudyModel {
  final CardModel card;
  // Bạn nên giữ tên là nextReviewTime cho đồng nhất với Backend
  final DateTime? nextReviewTime; 

  StudyModel({
    required this.card,
    this.nextReviewTime,
  });

  factory StudyModel.fromJson(Map<String, dynamic> json) {
    return StudyModel(
      // Backend trả về card nằm trực tiếp trong object chính
      card: CardModel.fromJson(json),
      // Dùng đúng key 'nextReviewTime' và kiểm tra null an toàn
      nextReviewTime: json['nextReviewTime'] != null
          ? DateTime.tryParse(json['nextReviewTime'].toString())
          : null,
    );
  }

  StudyEntity toEntity() {
    return StudyEntity(
      card: card.toEntity(),
      nextReviewTime: nextReviewTime,
    );
  }
}

/// Review Result Model
/// Example response from POST /study/review/:id:
/// {
///   "card": { ... full card object ... },
///   "nextReview": "2024-01-16T10:30:00.000Z",
///   "message": "Hard - You'll see this again soon"
/// }
class ReviewResultModel {
  final CardModel card;
  final DateTime nextReview;
  final String? message;

  ReviewResultModel({
    required this.card,
    required this.nextReview,
    this.message,
  });

  factory ReviewResultModel.fromJson(Map<String, dynamic> json) {
    return ReviewResultModel(
      card: CardModel.fromJson(json['card'] as Map<String, dynamic>),
      nextReview: DateTime.parse(json['nextReview'] as String),
      message: json['message'] as String?,
    );
  }

  ReviewResultEntity toEntity() {
    return ReviewResultEntity(
      card: card.toEntity(),
      nextReview: nextReview,
      message: message,
    );
  }
}
