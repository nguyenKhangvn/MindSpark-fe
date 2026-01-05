import '../../domain/entities/deck_entity.dart';

/// Deck Model - Data layer
class DeckModel {
  final String id;
  final String name;
  final String description;
  final String userId;
  final int cardCount;
  final String language;
  final String? imageUrl;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeckModel({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.cardCount,
    required this.language,
    this.imageUrl,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Deck',
      description: json['description'] as String? ?? '',
      userId: json['userId'] as String? ?? '',

      // --- SỬA LOGIC QUAN TRỌNG ---
      // JSON trả về: "_count": { "cards": 7 }
      // Phải map vào vào nested object
      cardCount: ((json['_count'] as Map<String, dynamic>?)?['cards'] as num?)
              ?.toInt() ??
          0,

      // Các trường bổ sung
      language: json['language'] as String? ?? 'en',
      imageUrl: json['imageUrl'] as String?, // Nullable
      isPublic: json['isPublic'] as bool? ?? false,

      // Parse Date an toàn
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // Hàm này dùng khi gửi data lên server (nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      // Khi gửi lên thường không gửi cardCount vì nó là computed field
      'language': language,
      'imageUrl': imageUrl,
      'isPublic': isPublic,
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
      language: language,
      imageUrl: imageUrl,
      isPublic: isPublic,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
