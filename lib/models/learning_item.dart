import 'package:fsrs/fsrs.dart';

/// Represents a learning item (vocabulary, grammar, kanji, etc.) tracked by FSRS
class LearningItem {
  final String id;
  final LearningItemType type;
  final Map<String, dynamic> content;
  final DateTime createdAt;
  Card? fsrsCard;

  LearningItem({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    this.fsrsCard,
  });

  /// Create a vocabulary learning item
  factory LearningItem.vocabulary({
    required String word,
    required String meaning,
    String? hiragana,
    String? romaji,
  }) {
    return LearningItem(
      id: 'vocab_$word',
      type: LearningItemType.vocabulary,
      content: {
        'word': word,
        'meaning': meaning,
        if (hiragana != null) 'hiragana': hiragana,
        if (romaji != null) 'romaji': romaji,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Create a grammar learning item
  factory LearningItem.grammar({
    required String title,
    required String explanation,
    List<String>? examples,
  }) {
    return LearningItem(
      id: 'grammar_$title',
      type: LearningItemType.grammar,
      content: {
        'title': title,
        'explanation': explanation,
        if (examples != null) 'examples': examples,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Create a kanji learning item
  factory LearningItem.kanji({
    required String kanji,
    required String meaning,
    required List<String> readings,
    List<String>? examples,
  }) {
    return LearningItem(
      id: 'kanji_$kanji',
      type: LearningItemType.kanji,
      content: {
        'kanji': kanji,
        'meaning': meaning,
        'readings': readings,
        if (examples != null) 'examples': examples,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Create a sentence learning item
  factory LearningItem.sentence({
    required String japanese,
    required String english,
    String? hiragana,
    String? romaji,
  }) {
    return LearningItem(
      id: 'sentence_$japanese',
      type: LearningItemType.sentence,
      content: {
        'japanese': japanese,
        'english': english,
        if (hiragana != null) 'hiragana': hiragana,
        if (romaji != null) 'romaji': romaji,
      },
      createdAt: DateTime.now(),
    );
  }

  /// Check if this item is due for review
  bool get isDue {
    if (fsrsCard == null) return true; // New items are always due
    return fsrsCard!.due.isBefore(DateTime.now());
  }

  /// Get the time until next review
  Duration? get timeUntilDue {
    if (fsrsCard == null) return null;
    return fsrsCard!.due.difference(DateTime.now());
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'fsrsCard': fsrsCard?.toMap(),
    };
  }

  /// Deserialize from JSON
  factory LearningItem.fromJson(Map<String, dynamic> json) {
    return LearningItem(
      id: json['id'] as String,
      type: LearningItemType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      content: Map<String, dynamic>.from(json['content'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      fsrsCard: json['fsrsCard'] != null
          ? Card.fromMap(Map<String, dynamic>.from(json['fsrsCard'] as Map))
          : null,
    );
  }
}

/// Types of learning items
enum LearningItemType {
  vocabulary,
  grammar,
  kanji,
  sentence,
}
