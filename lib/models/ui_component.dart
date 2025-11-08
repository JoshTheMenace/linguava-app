import 'package:flutter/material.dart';

/// Represents a dynamic UI component for Japanese learning
class UIComponent {
  final String id;
  final UIComponentType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  UIComponent({
    required this.id,
    required this.type,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a flashcard component
  factory UIComponent.flashcard({
    required String id,
    required String front,
    required String back,
    String? hiragana,
    String? romaji,
  }) {
    return UIComponent(
      id: id,
      type: UIComponentType.flashcard,
      data: {
        'front': front,
        'back': back,
        'hiragana': hiragana,
        'romaji': romaji,
      },
    );
  }

  /// Create a sentence review component
  factory UIComponent.sentenceReview({
    required String id,
    required String japanese,
    required String english,
    String? hiragana,
    String? romaji,
    String? explanation,
  }) {
    return UIComponent(
      id: id,
      type: UIComponentType.sentenceReview,
      data: {
        'japanese': japanese,
        'english': english,
        'hiragana': hiragana,
        'romaji': romaji,
        'explanation': explanation,
      },
    );
  }

  /// Create a speaking exercise component
  factory UIComponent.speakingExercise({
    required String id,
    required String prompt,
    required String targetPhrase,
    String? hiragana,
    String? romaji,
    String? hints,
  }) {
    return UIComponent(
      id: id,
      type: UIComponentType.speakingExercise,
      data: {
        'prompt': prompt,
        'targetPhrase': targetPhrase,
        'hiragana': hiragana,
        'romaji': romaji,
        'hints': hints,
      },
    );
  }

  /// Create a vocabulary list component
  factory UIComponent.vocabularyList({
    required String id,
    required String title,
    required List<Map<String, String>> words,
  }) {
    return UIComponent(
      id: id,
      type: UIComponentType.vocabularyList,
      data: {
        'title': title,
        'words': words,
      },
    );
  }

  /// Create a grammar explanation component
  factory UIComponent.grammarExplanation({
    required String id,
    required String title,
    required String explanation,
    List<String>? examples,
  }) {
    return UIComponent(
      id: id,
      type: UIComponentType.grammarExplanation,
      data: {
        'title': title,
        'explanation': explanation,
        'examples': examples ?? [],
      },
    );
  }

  /// Create a kanji practice component
  factory UIComponent.kanjiPractice({
    required String id,
    required String kanji,
    required String meaning,
    required List<String> readings,
    List<String>? examples,
  }) {
    return UIComponent(
      id: id,
      type: UIComponentType.kanjiPractice,
      data: {
        'kanji': kanji,
        'meaning': meaning,
        'readings': readings,
        'examples': examples ?? [],
      },
    );
  }

  /// Create a listening comprehension component
  factory UIComponent.listeningComprehension({
    required String id,
    required String instruction,
    required String targetSentence,
    String? hiragana,
    String? romaji,
  }) {
    return UIComponent(
      id: id,
      type: UIComponentType.listeningComprehension,
      data: {
        'instruction': instruction,
        'targetSentence': targetSentence,
        'hiragana': hiragana,
        'romaji': romaji,
      },
    );
  }
}

/// Types of UI components for Japanese learning
enum UIComponentType {
  flashcard,
  sentenceReview,
  speakingExercise,
  vocabularyList,
  grammarExplanation,
  kanjiPractice,
  listeningComprehension,
}

/// Extension to get display name for component types
extension UIComponentTypeExtension on UIComponentType {
  String get displayName {
    switch (this) {
      case UIComponentType.flashcard:
        return 'Flashcard';
      case UIComponentType.sentenceReview:
        return 'Sentence Review';
      case UIComponentType.speakingExercise:
        return 'Speaking Exercise';
      case UIComponentType.vocabularyList:
        return 'Vocabulary';
      case UIComponentType.grammarExplanation:
        return 'Grammar';
      case UIComponentType.kanjiPractice:
        return 'Kanji Practice';
      case UIComponentType.listeningComprehension:
        return 'Listening';
    }
  }

  IconData get icon {
    switch (this) {
      case UIComponentType.flashcard:
        return Icons.style;
      case UIComponentType.sentenceReview:
        return Icons.article;
      case UIComponentType.speakingExercise:
        return Icons.record_voice_over;
      case UIComponentType.vocabularyList:
        return Icons.list_alt;
      case UIComponentType.grammarExplanation:
        return Icons.book;
      case UIComponentType.kanjiPractice:
        return Icons.draw;
      case UIComponentType.listeningComprehension:
        return Icons.hearing;
    }
  }

  Color get color {
    switch (this) {
      case UIComponentType.flashcard:
        return Colors.pinkAccent;
      case UIComponentType.sentenceReview:
        return Colors.blueAccent;
      case UIComponentType.speakingExercise:
        return Colors.orangeAccent;
      case UIComponentType.vocabularyList:
        return Colors.greenAccent;
      case UIComponentType.grammarExplanation:
        return Colors.purpleAccent;
      case UIComponentType.kanjiPractice:
        return Colors.redAccent;
      case UIComponentType.listeningComprehension:
        return Colors.tealAccent;
    }
  }
}
