/// Model cho summary thống kê cards trong deck
class CardSummaryModel {
  final int total;
  final int newCards;
  final int learning;
  final int review;

  CardSummaryModel({
    required this.total,
    required this.newCards,
    required this.learning,
    required this.review,
  });

  factory CardSummaryModel.fromJson(Map<String, dynamic> json) {
    return CardSummaryModel(
      total: json['total'] ?? 0,
      newCards: json['new'] ?? 0,
      learning: json['learning'] ?? 0,
      review: json['review'] ?? 0,
    );
  }
}
