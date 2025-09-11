import '../database/database.dart';
import '../models/learning_path.dart' as models;
import '../models/lesson.dart' as models;
import '../models/user_path_progress.dart' as models;
import '../models/user_lesson_progress.dart' as models;
import '../models/study_card.dart';
import '../core/config/app_database.dart';

class LearningPathService {
  final AppDatabase _database;

  LearningPathService(this._database);

  // === PATH MANAGEMENT ===

  Future<List<models.LearningPath>> getAllPaths() async {
    return await _database.learningPathDao.getAllPathsAsModels();
  }

  Future<List<models.LearningPath>> getPathsByLanguage(String language) async {
    return await _database.learningPathDao.getPathsByLanguageAsModels(language);
  }

  Future<models.LearningPath?> getPathById(String pathId) async {
    final driftPath = await _database.learningPathDao.getPathById(pathId);
    return driftPath != null ? _database.learningPathDao.toModel(driftPath) : null;
  }

  // === LESSON MANAGEMENT ===

  Future<List<models.Lesson>> getLessonsForPath(String pathId) async {
    final lessons = await _database.lessonDao.getLessonsByPathAsModels(pathId);
    print('getLessonsForPath($pathId): Found ${lessons.length} lessons');
    return lessons;
  }

  Future<models.Lesson?> getLessonById(String lessonId) async {
    return await _database.lessonDao.getLessonByIdAsModel(lessonId);
  }

  Future<models.Lesson?> getNextLesson(String pathId, int currentOrderIndex) async {
    return await _database.lessonDao.getNextLessonAsModel(pathId, currentOrderIndex);
  }

  // === USER PROGRESS ===

  Future<models.UserPathProgress?> getUserPathProgress(String userId, String pathId) async {
    return await _database.userProgressDao.getPathProgressAsModel(userId, pathId);
  }

  Future<models.UserLessonProgress?> getUserLessonProgress(String userId, String lessonId) async {
    return await _database.userProgressDao.getLessonProgressAsModel(userId, lessonId);
  }

  Future<List<models.UserLessonProgress>> getUserLessonProgressForPath(String userId, String pathId) async {
    final lessons = await getLessonsForPath(pathId);
    final lessonIds = lessons.map((lesson) => lesson.id).toList();
    print('getUserLessonProgressForPath($userId, $pathId): Found ${lessons.length} lessons');
    
    final existingProgress = await _database.userProgressDao.getLessonProgressForPathAsModels(userId, lessonIds);
    print('Existing progress records: ${existingProgress.length}');
    
    // If no progress exists, create default progress records
    if (existingProgress.isEmpty && lessons.isNotEmpty) {
      print('Creating ${lessons.length} default progress records');
      final defaultProgress = lessons.map((lesson) {
        return models.UserLessonProgress(
          userId: userId,
          lessonId: lesson.id,
          isCompleted: false,
          isUnlocked: lesson.orderIndex == 0, // Only first lesson is unlocked by default
          completedCards: 0,
          totalCards: 0,
          timeSpent: 0,
          startedAt: null,
          completedAt: null,
          updatedAt: DateTime.now(),
        );
      }).toList();
      
      return defaultProgress;
    }
    
    return existingProgress;
  }

  // === PATH STARTING AND PROGRESSION ===

  Future<void> startLearningPath(String userId, String pathId) async {
    await _database.transaction(() async {
      // Start the path
      await _database.userProgressDao.startPath(userId, pathId);
      
      // Get all lessons for this path
      final lessons = await getLessonsForPath(pathId);
      
      // Initialize progress for all lessons
      for (final lesson in lessons) {
        final cardCount = await _database.lessonCardDao.getCardCountForLesson(lesson.id);
        final isFirstLesson = lesson.orderIndex == 0;
        await _database.userProgressDao.initializeLessonProgress(
          userId, 
          lesson.id, 
          cardCount,
          isUnlocked: isFirstLesson || lesson.prerequisites.isEmpty,
        );
      }
      
      // If there's a first lesson, set it as current
      if (lessons.isNotEmpty) {
        final firstLesson = lessons.first;
        await _updateCurrentLesson(userId, pathId, firstLesson.id);
      }
    });
  }

  // === LESSON COMPLETION ===

  Future<void> completeLesson(String userId, String lessonId) async {
    await _database.transaction(() async {
      // Mark lesson as completed
      await _database.userProgressDao.completeLesson(userId, lessonId);
      
      // Get the lesson details
      final lesson = await getLessonById(lessonId);
      if (lesson == null) return;
      
      // Get path progress
      final pathProgress = await getUserPathProgress(userId, lesson.pathId);
      if (pathProgress == null) return;
      
      // Update path progress
      final newCompletedLessons = pathProgress.completedLessons + 1;
      final allLessons = await getLessonsForPath(lesson.pathId);
      final progressPercentage = (newCompletedLessons / allLessons.length) * 100;
      
      final updatedPathProgress = pathProgress.copyWith(
        completedLessons: newCompletedLessons,
        progressPercentage: progressPercentage,
        lastStudiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completedAt: progressPercentage >= 100 ? DateTime.now() : null,
      );
      
      await _database.userProgressDao.updatePathProgress(updatedPathProgress);
      
      // Unlock dependent lessons
      await _unlockDependentLessons(userId, lessonId);
      
      // Set next lesson as current if path not completed
      if (progressPercentage < 100) {
        final nextLesson = await getNextLesson(lesson.pathId, lesson.orderIndex);
        if (nextLesson != null) {
          await _updateCurrentLesson(userId, lesson.pathId, nextLesson.id);
        }
      }
      
      // Add completed lesson cards to SRS system
      await _addLessonCardsToSRS(userId, lessonId);
    });
  }

  // === PRIVATE HELPER METHODS ===

  Future<void> _updateCurrentLesson(String userId, String pathId, String lessonId) async {
    final pathProgress = await getUserPathProgress(userId, pathId);
    if (pathProgress != null) {
      final updatedProgress = pathProgress.copyWith(
        currentLessonId: lessonId,
        lastStudiedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _database.userProgressDao.updatePathProgress(updatedProgress);
    }
  }

  Future<void> _unlockDependentLessons(String userId, String completedLessonId) async {
    // Get lessons that have this lesson as a prerequisite
    final dependentLessons = await _database.lessonDao.getDependentLessons(completedLessonId);
    
    for (final dependentLesson in dependentLessons) {
      // Check if all prerequisites are now completed
      final allPrerequisitesCompleted = await _areAllPrerequisitesCompleted(
        userId, 
        dependentLesson.prerequisites,
      );
      
      if (allPrerequisitesCompleted) {
        await _database.userProgressDao.unlockLesson(userId, dependentLesson.id);
      }
    }
  }

  Future<bool> _areAllPrerequisitesCompleted(String userId, List<String> prerequisiteIds) async {
    for (final prerequisiteId in prerequisiteIds) {
      final progress = await getUserLessonProgress(userId, prerequisiteId);
      if (progress == null || !progress.isCompleted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _addLessonCardsToSRS(String userId, String lessonId) async {
    // Get all cards for this lesson
    final cardIds = await _database.lessonCardDao.getCardIdsForLesson(lessonId);
    
    // For each card, initialize it in the SRS system if not already present
    for (final cardId in cardIds) {
      final existingStudyCard = await _database.studyCardDao.getStudyCard(cardId);
      if (existingStudyCard == null) {
        // Create a simple default FSRS data map for now
        final defaultFsrsData = {
          'due': DateTime.now().millisecondsSinceEpoch,
          'stability': 1.0,
          'difficulty': 5.0,
          'elapsed_days': 0,
          'scheduled_days': 0,
          'reps': 0,
          'lapses': 0,
          'state': 0, // New state
          'last_review': null,
        };
        
        // We'll need to create a proper FSRS Card object here
        // For now, we'll skip this and let the cards be initialized 
        // when the user first studies them through the normal flow
        print('Card $cardId completed in lesson $lessonId - ready for SRS');
      }
    }
  }

  // === PUBLIC UTILITY METHODS ===

  Future<List<String>> getAvailableLanguages() async {
    final allPaths = await getAllPaths();
    final languages = allPaths.map((path) => path.language).toSet().toList();
    languages.sort();
    return languages;
  }

  Future<List<String>> getAvailableCategories() async {
    final allPaths = await getAllPaths();
    final categories = allPaths.map((path) => path.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<List<models.LearningPath>> getRecommendedPaths(String userId) async {
    // For now, just return official paths
    // In the future, this could be more sophisticated based on user progress
    return await _database.learningPathDao.getOfficialPaths()
        .then((paths) => paths.map((path) => _database.learningPathDao.toModel(path)).toList());
  }

  Future<List<models.UserPathProgress>> getUserActivePaths(String userId) async {
    final allProgress = await _database.userProgressDao.getAllPathProgress(userId);
    return allProgress
        .map((progress) => _database.userProgressDao.toPathModel(progress))
        .where((progress) => progress != null && progress.isStarted && !progress.isCompleted)
        .cast<models.UserPathProgress>()
        .toList();
  }

  Future<Map<String, dynamic>> getPathStatistics(String userId, String pathId) async {
    final pathProgress = await getUserPathProgress(userId, pathId);
    final lessonProgress = await getUserLessonProgressForPath(userId, pathId);
    
    if (pathProgress == null) {
      return {
        'isStarted': false,
        'completedLessons': 0,
        'totalLessons': 0,
        'progressPercentage': 0.0,
        'totalTimeSpent': 0,
        'unlockedLessons': 0,
      };
    }
    
    final unlockedLessons = lessonProgress.where((progress) => progress.isUnlocked).length;
    final totalLessons = lessonProgress.length;
    
    return {
      'isStarted': pathProgress.isStarted,
      'completedLessons': pathProgress.completedLessons,
      'totalLessons': totalLessons,
      'progressPercentage': pathProgress.progressPercentage,
      'totalTimeSpent': pathProgress.totalTimeSpent,
      'unlockedLessons': unlockedLessons,
      'currentLessonId': pathProgress.currentLessonId,
      'lastStudiedAt': pathProgress.lastStudiedAt,
    };
  }
}