import 'package:equatable/equatable.dart';

/// Deck Entity - Domain layer
class DeckEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String userId;
  final int cardCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeckEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.cardCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        userId,
        cardCount,
        createdAt,
        updatedAt,
      ];
}
