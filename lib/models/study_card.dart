import 'flashcard.dart';

enum StudyGrade { again, hard, good, easy }

class StudyCard {
  final Flashcard flashcard;
  final bool isNew;
  final int daysUntilReview;
  final double stability;
  final double difficulty;
  final int reviewCount;
  final DateTime? lastReview;
  final bool isLearning;

  const StudyCard({
    required this.flashcard,
    this.isNew = false,
    this.daysUntilReview = 0,
    this.stability = 1.0,
    this.difficulty = 5.0,
    this.reviewCount = 0,
    this.lastReview,
    this.isLearning = false,
  });

  StudyCard copyWith({
    Flashcard? flashcard,
    bool? isNew,
    int? daysUntilReview,
    double? stability,
    double? difficulty,
    int? reviewCount,
    DateTime? lastReview,
    bool? isLearning,
  }) {
    return StudyCard(
      flashcard: flashcard ?? this.flashcard,
      isNew: isNew ?? this.isNew,
      daysUntilReview: daysUntilReview ?? this.daysUntilReview,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReview: lastReview ?? this.lastReview,
      isLearning: isLearning ?? this.isLearning,
    );
  }

  String get cardStatus {
    if (isNew) return 'New';
    if (isLearning) return 'Learning';
    if (daysUntilReview == 0) return 'Due';
    if (daysUntilReview < 0) return 'Overdue';
    return 'Scheduled';
  }

  String get nextReviewText {
    if (isNew) return 'First review';
    if (isLearning) return 'In learning phase';
    if (daysUntilReview == 0) return 'Due now';
    if (daysUntilReview == 1) return 'Due tomorrow';
    if (daysUntilReview < 0) return '${-daysUntilReview} days overdue';
    return 'Due in $daysUntilReview days';
  }
}