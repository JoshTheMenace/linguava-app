class Flashcard {
  final String id;
  final String front;
  final String back;
  final String? imageUrl;
  final String? audioUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int difficulty;
  final int timesReviewed;
  final int correctCount;
  final int incorrectCount;
  final DateTime? lastReviewed;
  final DateTime? nextReview;

  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.imageUrl,
    this.audioUrl,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.difficulty = 1,
    this.timesReviewed = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.lastReviewed,
    this.nextReview,
  });

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    String? imageUrl,
    String? audioUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? difficulty,
    int? timesReviewed,
    int? correctCount,
    int? incorrectCount,
    DateTime? lastReviewed,
    DateTime? nextReview,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      difficulty: difficulty ?? this.difficulty,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReview: nextReview ?? this.nextReview,
    );
  }

  double get accuracyRate {
    if (timesReviewed == 0) return 0.0;
    return correctCount / timesReviewed;
  }

  bool get isDue {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview!);
  }
}