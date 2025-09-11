class UserLessonProgress {
  final String userId;
  final String lessonId;
  final bool isCompleted;
  final bool isUnlocked;
  final int completedCards;
  final int totalCards;
  final int timeSpent; // minutes
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const UserLessonProgress({
    required this.userId,
    required this.lessonId,
    required this.isCompleted,
    required this.isUnlocked,
    required this.completedCards,
    required this.totalCards,
    required this.timeSpent,
    this.startedAt,
    this.completedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'lessonId': lessonId,
    'isCompleted': isCompleted,
    'isUnlocked': isUnlocked,
    'completedCards': completedCards,
    'totalCards': totalCards,
    'timeSpent': timeSpent,
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserLessonProgress.fromJson(Map<String, dynamic> json) => UserLessonProgress(
    userId: json['userId'] as String,
    lessonId: json['lessonId'] as String,
    isCompleted: json['isCompleted'] as bool,
    isUnlocked: json['isUnlocked'] as bool,
    completedCards: json['completedCards'] as int,
    totalCards: json['totalCards'] as int,
    timeSpent: json['timeSpent'] as int,
    startedAt: json['startedAt'] != null 
        ? DateTime.parse(json['startedAt'] as String) 
        : null,
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'] as String) 
        : null,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  UserLessonProgress copyWith({
    String? userId,
    String? lessonId,
    bool? isCompleted,
    bool? isUnlocked,
    int? completedCards,
    int? totalCards,
    int? timeSpent,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) => UserLessonProgress(
    userId: userId ?? this.userId,
    lessonId: lessonId ?? this.lessonId,
    isCompleted: isCompleted ?? this.isCompleted,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    completedCards: completedCards ?? this.completedCards,
    totalCards: totalCards ?? this.totalCards,
    timeSpent: timeSpent ?? this.timeSpent,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  double get progressPercentage => 
      totalCards > 0 ? (completedCards / totalCards) * 100 : 0.0;

  bool get isStarted => startedAt != null;
  bool get isInProgress => isStarted && !isCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLessonProgress &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          lessonId == other.lessonId;

  @override
  int get hashCode => Object.hash(userId, lessonId);

  @override
  String toString() => 'UserLessonProgress(userId: $userId, lessonId: $lessonId, completed: $isCompleted, unlocked: $isUnlocked)';
}