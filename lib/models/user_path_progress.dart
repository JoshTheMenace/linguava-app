class UserPathProgress {
  final String userId;
  final String pathId;
  final String? currentLessonId;
  final int completedLessons;
  final int totalTimeSpent; // minutes
  final double progressPercentage;
  final DateTime startedAt;
  final DateTime? lastStudiedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const UserPathProgress({
    required this.userId,
    required this.pathId,
    this.currentLessonId,
    required this.completedLessons,
    required this.totalTimeSpent,
    required this.progressPercentage,
    required this.startedAt,
    this.lastStudiedAt,
    this.completedAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'pathId': pathId,
    'currentLessonId': currentLessonId,
    'completedLessons': completedLessons,
    'totalTimeSpent': totalTimeSpent,
    'progressPercentage': progressPercentage,
    'startedAt': startedAt.toIso8601String(),
    'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserPathProgress.fromJson(Map<String, dynamic> json) => UserPathProgress(
    userId: json['userId'] as String,
    pathId: json['pathId'] as String,
    currentLessonId: json['currentLessonId'] as String?,
    completedLessons: json['completedLessons'] as int,
    totalTimeSpent: json['totalTimeSpent'] as int,
    progressPercentage: (json['progressPercentage'] as num).toDouble(),
    startedAt: DateTime.parse(json['startedAt'] as String),
    lastStudiedAt: json['lastStudiedAt'] != null 
        ? DateTime.parse(json['lastStudiedAt'] as String) 
        : null,
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'] as String) 
        : null,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  UserPathProgress copyWith({
    String? userId,
    String? pathId,
    String? currentLessonId,
    int? completedLessons,
    int? totalTimeSpent,
    double? progressPercentage,
    DateTime? startedAt,
    DateTime? lastStudiedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) => UserPathProgress(
    userId: userId ?? this.userId,
    pathId: pathId ?? this.pathId,
    currentLessonId: currentLessonId ?? this.currentLessonId,
    completedLessons: completedLessons ?? this.completedLessons,
    totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    progressPercentage: progressPercentage ?? this.progressPercentage,
    startedAt: startedAt ?? this.startedAt,
    lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
    completedAt: completedAt ?? this.completedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  bool get isCompleted => completedAt != null;
  bool get isStarted => completedLessons > 0 || lastStudiedAt != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPathProgress &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          pathId == other.pathId;

  @override
  int get hashCode => Object.hash(userId, pathId);

  @override
  String toString() => 'UserPathProgress(userId: $userId, pathId: $pathId, progress: ${progressPercentage.toStringAsFixed(1)}%)';
}