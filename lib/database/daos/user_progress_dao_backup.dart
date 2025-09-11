import 'package:drift/drift.dart';
import '../database.dart';
import '../../models/user_path_progress.dart' as path_model;
import '../../models/user_lesson_progress.dart' as lesson_model;

part 'user_progress_dao.g.dart';

@DriftAccessor(tables: [UserPathProgress, UserLessonProgress])
class UserProgressDao extends DatabaseAccessor<AppDatabase> with _$UserProgressDaoMixin {
  UserProgressDao(AppDatabase db) : super(db);

  // === PATH PROGRESS METHODS ===

  // Get user's progress for a path
  Future<UserPathProgressData?> getPathProgress(String userId, String pathId) async {
    return await (select(userPathProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.pathId.equals(pathId)))
        .getSingleOrNull();
  }

  // Get all path progress for user
  Future<List<UserPathProgressData>> getAllPathProgress(String userId) async {
    return await (select(userPathProgress)
          ..where((progress) => progress.userId.equals(userId))
          ..orderBy([(progress) => OrderingTerm.desc(progress.lastStudiedAt)]))
        .get();
  }

  // Start a learning path
  Future<void> startPath(String userId, String pathId) async {
    final now = DateTime.now();
    final progressData = UserPathProgressCompanion.insert(
      userId: userId,
      pathId: pathId,
      currentLessonId: const Value(null),
      completedLessons: const Value(0),
      totalTimeSpent: const Value(0),
      progressPercentage: const Value(0.0),
      startedAt: now,
      lastStudiedAt: const Value(null),
      completedAt: const Value(null),
      updatedAt: now,
    );

    await into(userPathProgress).insertOnConflictUpdate(progressData);
  }

  // Update path progress
  Future<void> updatePathProgress(path_model.UserPathProgress progress) async {
    final progressData = UserPathProgress(
      userId: progress.userId,
      pathId: progress.pathId,
      currentLessonId: progress.currentLessonId,
      completedLessons: progress.completedLessons,
      totalTimeSpent: progress.totalTimeSpent,
      progressPercentage: progress.progressPercentage,
      startedAt: progress.startedAt,
      lastStudiedAt: progress.lastStudiedAt,
      completedAt: progress.completedAt,
      updatedAt: progress.updatedAt,
    );

    await update(userPathProgress).replace(progressData);
  }

  // Complete a learning path
  Future<void> completePath(String userId, String pathId) async {
    final now = DateTime.now();
    await (update(userPathProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.pathId.equals(pathId)))
        .write(UserPathProgressCompanion(
          completedAt: Value(now),
          progressPercentage: const Value(100.0),
          updatedAt: Value(now),
        ));
  }

  // === LESSON PROGRESS METHODS ===

  // Get user's progress for a lesson
  Future<UserLessonProgress?> getLessonProgress(String userId, String lessonId) async {
    return await (select(userLessonProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.lessonId.equals(lessonId)))
        .getSingleOrNull();
  }

  // Get all lesson progress for user and path
  Future<List<UserLessonProgress>> getLessonProgressForPath(String userId, List<String> lessonIds) async {
    return await (select(userLessonProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.lessonId.isIn(lessonIds)))
        .get();
  }

  // Initialize lesson progress
  Future<void> initializeLessonProgress(String userId, String lessonId, int totalCards, {bool isUnlocked = false}) async {
    final now = DateTime.now();
    final progressData = UserLessonProgress(
      userId: userId,
      lessonId: lessonId,
      isCompleted: false,
      isUnlocked: isUnlocked,
      completedCards: 0,
      totalCards: totalCards,
      timeSpent: 0,
      startedAt: null,
      completedAt: null,
      updatedAt: now,
    );

    await into(userLessonProgress).insertOnConflictUpdate(progressData);
  }

  // Start a lesson
  Future<void> startLesson(String userId, String lessonId) async {
    final now = DateTime.now();
    await (update(userLessonProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.lessonId.equals(lessonId)))
        .write(UserLessonProgressCompanion(
          startedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  // Update lesson progress
  Future<void> updateLessonProgress(lesson_model.UserLessonProgress progress) async {
    final progressData = UserLessonProgress(
      userId: progress.userId,
      lessonId: progress.lessonId,
      isCompleted: progress.isCompleted,
      isUnlocked: progress.isUnlocked,
      completedCards: progress.completedCards,
      totalCards: progress.totalCards,
      timeSpent: progress.timeSpent,
      startedAt: progress.startedAt,
      completedAt: progress.completedAt,
      updatedAt: progress.updatedAt,
    );

    await update(userLessonProgress).replace(progressData);
  }

  // Complete a lesson
  Future<void> completeLesson(String userId, String lessonId) async {
    final now = DateTime.now();
    await (update(userLessonProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.lessonId.equals(lessonId)))
        .write(UserLessonProgressCompanion(
          isCompleted: const Value(true),
          completedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  // Unlock a lesson
  Future<void> unlockLesson(String userId, String lessonId) async {
    final now = DateTime.now();
    await (update(userLessonProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.lessonId.equals(lessonId)))
        .write(UserLessonProgressCompanion(
          isUnlocked: const Value(true),
          updatedAt: Value(now),
        ));
  }

  // Unlock multiple lessons
  Future<void> unlockLessons(String userId, List<String> lessonIds) async {
    final now = DateTime.now();
    await (update(userLessonProgress)
          ..where((progress) => 
              progress.userId.equals(userId) & 
              progress.lessonId.isIn(lessonIds)))
        .write(UserLessonProgressCompanion(
          isUnlocked: const Value(true),
          updatedAt: Value(now),
        ));
  }

  // Add time to lesson
  Future<void> addTimeToLesson(String userId, String lessonId, int additionalMinutes) async {
    final now = DateTime.now();
    final currentProgress = await getLessonProgress(userId, lessonId);
    
    if (currentProgress != null) {
      await (update(userLessonProgress)
            ..where((progress) => 
                progress.userId.equals(userId) & 
                progress.lessonId.equals(lessonId)))
          .write(UserLessonProgressCompanion(
            timeSpent: Value(currentProgress.timeSpent + additionalMinutes),
            updatedAt: Value(now),
          ));
    }
  }

  // Convert Drift data to models
  path_model.UserPathProgress toPathModel(UserPathProgress data) {
    return path_model.UserPathProgress(
      userId: data.userId,
      pathId: data.pathId,
      currentLessonId: data.currentLessonId,
      completedLessons: data.completedLessons,
      totalTimeSpent: data.totalTimeSpent,
      progressPercentage: data.progressPercentage,
      startedAt: data.startedAt,
      lastStudiedAt: data.lastStudiedAt,
      completedAt: data.completedAt,
      updatedAt: data.updatedAt,
    );
  }

  lesson_model.UserLessonProgress toLessonModel(UserLessonProgress data) {
    return lesson_model.UserLessonProgress(
      userId: data.userId,
      lessonId: data.lessonId,
      isCompleted: data.isCompleted,
      isUnlocked: data.isUnlocked,
      completedCards: data.completedCards,
      totalCards: data.totalCards,
      timeSpent: data.timeSpent,
      startedAt: data.startedAt,
      completedAt: data.completedAt,
      updatedAt: data.updatedAt,
    );
  }

  // Get path progress as model
  Future<path_model.UserPathProgress?> getPathProgressAsModel(String userId, String pathId) async {
    final data = await getPathProgress(userId, pathId);
    return data != null ? toPathModel(data) : null;
  }

  // Get lesson progress as model
  Future<lesson_model.UserLessonProgress?> getLessonProgressAsModel(String userId, String lessonId) async {
    final data = await getLessonProgress(userId, lessonId);
    return data != null ? toLessonModel(data) : null;
  }

  // Get all lesson progress for path as models
  Future<List<lesson_model.UserLessonProgress>> getLessonProgressForPathAsModels(String userId, List<String> lessonIds) async {
    final data = await getLessonProgressForPath(userId, lessonIds);
    return data.map((progress) => toLessonModel(progress)).toList();
  }
}