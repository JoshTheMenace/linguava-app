import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_path.dart' as models;
import '../models/lesson.dart' as models;
import '../models/user_path_progress.dart' as models;
import '../models/user_lesson_progress.dart' as models;
import '../services/learning_path_service.dart';
import '../services/learning_path_template_service.dart';
import '../core/config/app_database.dart';

// Database provider
final learningPathServiceProvider = Provider<LearningPathService>((ref) {
  final database = ref.watch(databaseProvider);
  return LearningPathService(database);
});

// Template service provider
final learningPathTemplateServiceProvider = Provider<LearningPathTemplateService>((ref) {
  final database = ref.watch(databaseProvider);
  return LearningPathTemplateService(database);
});

// Learning paths providers
final learningPathsProvider = FutureProvider<List<models.LearningPath>>((ref) async {
  final service = ref.watch(learningPathServiceProvider);
  
  // Initialize templates if needed
  final templateService = ref.watch(learningPathTemplateServiceProvider);
  final areInitialized = await templateService.areTemplatesInitialized();
  if (!areInitialized) {
    await templateService.initializeAllTemplates();
  }
  
  return await service.getAllPaths();
});

// Single learning path provider
final learningPathProvider = FutureProvider.family<models.LearningPath?, String>((ref, pathId) async {
  final service = ref.watch(learningPathServiceProvider);
  return await service.getPathById(pathId);
});

// Path lessons provider
final pathLessonsProvider = FutureProvider.family<List<models.Lesson>, String>((ref, pathId) async {
  final service = ref.watch(learningPathServiceProvider);
  return await service.getLessonsForPath(pathId);
});

// User's active paths provider
final activePathsProvider = FutureProvider<List<models.UserPathProgress>>((ref) async {
  final service = ref.watch(learningPathServiceProvider);
  // TODO: Replace with actual user ID from auth
  return await service.getUserActivePaths('current_user');
});

// User's path progress provider
final pathProgressProvider = FutureProvider.family<models.UserPathProgress?, String>((ref, pathId) async {
  final service = ref.watch(learningPathServiceProvider);
  // TODO: Replace with actual user ID from auth
  return await service.getUserPathProgress('current_user', pathId);
});

// User's lesson progress for a path
final lessonsProgressProvider = FutureProvider.family<List<models.UserLessonProgress>, String>((ref, pathId) async {
  final service = ref.watch(learningPathServiceProvider);
  // TODO: Replace with actual user ID from auth
  return await service.getUserLessonProgressForPath('current_user', pathId);
});

// Single lesson progress provider
final lessonProgressProvider = FutureProvider.family<models.UserLessonProgress?, String>((ref, lessonId) async {
  final service = ref.watch(learningPathServiceProvider);
  // TODO: Replace with actual user ID from auth
  return await service.getUserLessonProgress('current_user', lessonId);
});

// Path statistics provider
final pathStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, pathId) async {
  final service = ref.watch(learningPathServiceProvider);
  // TODO: Replace with actual user ID from auth
  return await service.getPathStatistics('current_user', pathId);
});

// Available languages provider
final availableLanguagesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(learningPathServiceProvider);
  return await service.getAvailableLanguages();
});

// Available categories provider
final availableCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(learningPathServiceProvider);
  return await service.getAvailableCategories();
});

// Recommended paths provider
final recommendedPathsProvider = FutureProvider<List<models.LearningPath>>((ref) async {
  final service = ref.watch(learningPathServiceProvider);
  // TODO: Replace with actual user ID from auth
  return await service.getRecommendedPaths('current_user');
});

// Filtered paths provider
final filteredPathsProvider = FutureProvider.family<List<models.LearningPath>, FilterParams>((ref, params) async {
  final allPaths = await ref.watch(learningPathsProvider.future);
  
  return allPaths.where((path) {
    final languageMatch = params.language == null || params.language == 'All' || path.language == params.language;
    final categoryMatch = params.category == null || params.category == 'All' || path.category == params.category;
    final levelMatch = params.level == null || params.level == 'All' || path.level == params.level;
    
    return languageMatch && categoryMatch && levelMatch;
  }).toList();
});

// Search paths provider
final searchPathsProvider = FutureProvider.family<List<models.LearningPath>, String>((ref, query) async {
  final allPaths = await ref.watch(learningPathsProvider.future);
  
  if (query.isEmpty) return allPaths;
  
  final lowercaseQuery = query.toLowerCase();
  return allPaths.where((path) {
    return path.name.toLowerCase().contains(lowercaseQuery) ||
           path.description.toLowerCase().contains(lowercaseQuery) ||
           path.language.toLowerCase().contains(lowercaseQuery) ||
           path.category.toLowerCase().contains(lowercaseQuery);
  }).toList();
});

// Helper class for filter parameters
class FilterParams {
  final String? language;
  final String? category;
  final String? level;

  const FilterParams({
    this.language,
    this.category,
    this.level,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterParams &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          category == other.category &&
          level == other.level;

  @override
  int get hashCode => Object.hash(language, category, level);
}