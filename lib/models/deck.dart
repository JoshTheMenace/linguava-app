import 'flashcard.dart';

class Deck {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalCards;
  final int reviewedCards;
  final int masteredCards;
  final String language;
  final String difficulty;
  final bool isPublic;
  final String creatorId;

  const Deck({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.totalCards = 0,
    this.reviewedCards = 0,
    this.masteredCards = 0,
    this.language = 'en',
    this.difficulty = 'beginner',
    this.isPublic = false,
    required this.creatorId,
  });

  Deck copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalCards,
    int? reviewedCards,
    int? masteredCards,
    String? language,
    String? difficulty,
    bool? isPublic,
    String? creatorId,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCards: totalCards ?? this.totalCards,
      reviewedCards: reviewedCards ?? this.reviewedCards,
      masteredCards: masteredCards ?? this.masteredCards,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      isPublic: isPublic ?? this.isPublic,
      creatorId: creatorId ?? this.creatorId,
    );
  }

  double get progressPercentage {
    if (totalCards == 0) return 0.0;
    return reviewedCards / totalCards;
  }

  double get masteryPercentage {
    if (totalCards == 0) return 0.0;
    return masteredCards / totalCards;
  }

  int get pendingCards => totalCards - reviewedCards;
}