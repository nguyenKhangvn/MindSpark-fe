import '../../domain/entities/deck_entity.dart';

/// Deck Model - Data layer
/// Example response from GET /decks:
/// [
///   {
///     "id": "deck-123",
///     "name": "Spanish Vocabulary",
///     "description": "Basic Spanish words",
///     "userId": "user-456",
///     "cardCount": 25,
///     "createdAt": "2024-01-15T10:30:00.000Z",
///     "updatedAt": "2024-01-15T10:30:00.000Z"
///   }
/// ]
class DeckModel {
  final String id;
  final String name;
  final String description;
  final String userId;
  final int cardCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeckModel({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.cardCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      userId: json['userId'] as String,
      cardCount: json['cardCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'cardCount': cardCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DeckEntity toEntity() {
    return DeckEntity(
      id: id,
      name: name,
      description: description,
      userId: userId,
      cardCount: cardCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
