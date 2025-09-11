import 'package:drift/drift.dart';
import '../database.dart';
import '../../models/learning_path.dart' as model;

part 'learning_path_dao.g.dart';

@DriftAccessor(tables: [LearningPaths])
class LearningPathDao extends DatabaseAccessor<AppDatabase> with _$LearningPathDaoMixin {
  LearningPathDao(AppDatabase db) : super(db);

  // Get all learning paths
  Future<List<LearningPath>> getAllPaths() async {
    return await select(learningPaths).get();
  }

  // Get learning paths by language
  Future<List<LearningPath>> getPathsByLanguage(String language) async {
    return await (select(learningPaths)
          ..where((path) => path.language.equals(language)))
        .get();
  }

  // Get learning paths by category
  Future<List<LearningPath>> getPathsByCategory(String category) async {
    return await (select(learningPaths)
          ..where((path) => path.category.equals(category)))
        .get();
  }

  // Get official learning paths
  Future<List<LearningPath>> getOfficialPaths() async {
    return await (select(learningPaths)
          ..where((path) => path.isOfficial.equals(true)))
        .get();
  }

  // Get learning path by ID
  Future<LearningPath?> getPathById(String id) async {
    return await (select(learningPaths)
          ..where((path) => path.id.equals(id)))
        .getSingleOrNull();
  }

  // Search learning paths by name
  Future<List<LearningPath>> searchPaths(String query) async {
    return await (select(learningPaths)
          ..where((path) => 
              path.name.contains(query) | 
              path.description.contains(query)))
        .get();
  }

  // Insert learning path
  Future<void> insertPath(model.LearningPath learningPath) async {
    final pathData = LearningPath(
      id: learningPath.id,
      name: learningPath.name,
      description: learningPath.description,
      language: learningPath.language,
      level: learningPath.level,
      category: learningPath.category,
      imageUrl: learningPath.imageUrl,
      estimatedHours: learningPath.estimatedHours,
      totalLessons: learningPath.totalLessons,
      isOfficial: learningPath.isOfficial,
      createdAt: learningPath.createdAt,
      updatedAt: learningPath.updatedAt,
    );

    await into(learningPaths).insert(pathData);
  }

  // Update learning path
  Future<void> updatePath(model.LearningPath learningPath) async {
    final pathData = LearningPath(
      id: learningPath.id,
      name: learningPath.name,
      description: learningPath.description,
      language: learningPath.language,
      level: learningPath.level,
      category: learningPath.category,
      imageUrl: learningPath.imageUrl,
      estimatedHours: learningPath.estimatedHours,
      totalLessons: learningPath.totalLessons,
      isOfficial: learningPath.isOfficial,
      createdAt: learningPath.createdAt,
      updatedAt: learningPath.updatedAt,
    );

    await update(learningPaths).replace(pathData);
  }

  // Delete learning path
  Future<void> deletePath(String id) async {
    await (delete(learningPaths)..where((path) => path.id.equals(id))).go();
  }

  // Upsert learning path
  Future<void> upsertPath(model.LearningPath learningPath) async {
    final pathData = LearningPath(
      id: learningPath.id,
      name: learningPath.name,
      description: learningPath.description,
      language: learningPath.language,
      level: learningPath.level,
      category: learningPath.category,
      imageUrl: learningPath.imageUrl,
      estimatedHours: learningPath.estimatedHours,
      totalLessons: learningPath.totalLessons,
      isOfficial: learningPath.isOfficial,
      createdAt: learningPath.createdAt,
      updatedAt: learningPath.updatedAt,
    );

    await into(learningPaths).insertOnConflictUpdate(pathData);
  }

  // Convert Drift data to model
  model.LearningPath toModel(LearningPath data) {
    return model.LearningPath(
      id: data.id,
      name: data.name,
      description: data.description,
      language: data.language,
      level: data.level,
      category: data.category,
      imageUrl: data.imageUrl,
      estimatedHours: data.estimatedHours,
      totalLessons: data.totalLessons,
      isOfficial: data.isOfficial,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  // Get all paths as models
  Future<List<model.LearningPath>> getAllPathsAsModels() async {
    final paths = await getAllPaths();
    return paths.map((path) => toModel(path)).toList();
  }

  // Get paths by language as models
  Future<List<model.LearningPath>> getPathsByLanguageAsModels(String language) async {
    final paths = await getPathsByLanguage(language);
    return paths.map((path) => toModel(path)).toList();
  }
}