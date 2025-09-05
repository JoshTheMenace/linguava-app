import 'package:fsrs/fsrs.dart';
import 'flashcard.dart';

enum StudyGrade { again, hard, good, easy }

class StudyCard {
  final Flashcard flashcard;
  final Card fsrsCard; // The actual FSRS card data
  final bool isNew;
  final bool isLearning;
  final int reviewCount;
  final double difficulty;
  final double stability;
  final int daysUntilReview;
  final DateTime? lastReviewDate;
  final DateTime? nextReviewDate;
  final double? easeFactor;
  final int? interval;
  final int? lapses;

  const StudyCard({
    required this.flashcard,
    required this.fsrsCard,
    this.isNew = true,
    this.isLearning = false,
    this.reviewCount = 0,
    required this.difficulty,
    required this.stability,
    this.daysUntilReview = 0,
    this.lastReviewDate,
    this.nextReviewDate,
    this.easeFactor,
    this.interval,
    this.lapses,
  });

  StudyCard copyWith({
    Flashcard? flashcard,
    Card? fsrsCard,
    bool? isNew,
    bool? isLearning,
    int? reviewCount,
    double? difficulty,
    double? stability,
    int? daysUntilReview,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
    double? easeFactor,
    int? interval,
    int? lapses,
  }) {
    return StudyCard(
      flashcard: flashcard ?? this.flashcard,
      fsrsCard: fsrsCard ?? this.fsrsCard,
      isNew: isNew ?? this.isNew,
      isLearning: isLearning ?? this.isLearning,
      reviewCount: reviewCount ?? this.reviewCount,
      difficulty: difficulty ?? this.difficulty,
      stability: stability ?? this.stability,
      daysUntilReview: daysUntilReview ?? this.daysUntilReview,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      lapses: lapses ?? this.lapses,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'flashcardId': flashcard.id,
      'fsrsCard': fsrsCard.toMap(),
      'isNew': isNew,
      'isLearning': isLearning,
      'reviewCount': reviewCount,
      'daysUntilReview': daysUntilReview,
      'lastReviewDate': lastReviewDate?.toIso8601String(),
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'easeFactor': easeFactor,
      'interval': interval,
      'lapses': lapses,
    };
  }

  /// Create from JSON for storage
  static StudyCard fromJson(Map<String, dynamic> json, Flashcard flashcard) {
    final fsrsCardData = json['fsrsCard'] as Map<String, dynamic>;
    final fsrsCard = Card.fromMap(fsrsCardData);

    return StudyCard(
      flashcard: flashcard,
      fsrsCard: fsrsCard,
      isNew: json['isNew'] ?? true,
      isLearning: json['isLearning'] ?? false,
      reviewCount: json['reviewCount'] ?? 0,
      difficulty: fsrsCard.difficulty ?? 5.0,
      stability: fsrsCard.stability ?? 1.0,
      daysUntilReview: json['daysUntilReview'] ?? 0,
      lastReviewDate: json['lastReviewDate'] != null 
          ? DateTime.parse(json['lastReviewDate'])
          : null,
      nextReviewDate: json['nextReviewDate'] != null 
          ? DateTime.parse(json['nextReviewDate'])
          : null,
      easeFactor: json['easeFactor'],
      interval: json['interval'],
      lapses: json['lapses'],
    );
  }

  String get cardStatus {
    if (isNew) return 'New';
    if (isLearning) return 'Learning';
    if (daysUntilReview <= 0) return 'Due';
    if (daysUntilReview == 1) return 'Soon';
    return 'Scheduled';
  }

  String get nextReviewText {
    if (isNew) return 'New card';
    if (nextReviewDate == null) return 'Not scheduled';
    
    final now = DateTime.now();
    final difference = nextReviewDate!.difference(now);
    
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Due now';
    }
  }

  /// Check if card is due for review
  bool get isDue {
    if (nextReviewDate == null) return isNew;
    return nextReviewDate!.isBefore(DateTime.now()) || 
           nextReviewDate!.isAtSameMomentAs(DateTime.now());
  }

  /// Get FSRS state as string
  String get fsrsState {
    switch (fsrsCard.state) {
      case State.learning:
        return 'Learning';
      case State.review:
        return 'Review';
      case State.relearning:
        return 'Relearning';
    }
  }

  /// Get formatted stability
  String get formattedStability {
    if (stability < 1) {
      return '${(stability * 24).toStringAsFixed(0)}h';
    } else if (stability < 30) {
      return '${stability.toStringAsFixed(1)}d';
    } else if (stability < 365) {
      return '${(stability / 30).toStringAsFixed(1)}m';
    } else {
      return '${(stability / 365).toStringAsFixed(1)}y';
    }
  }
}