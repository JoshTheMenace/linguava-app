import 'dart:convert';
import 'package:drift/drift.dart';
import '../database.dart';
import '../../models/lesson.dart' as model;

part 'lesson_dao.g.dart';

@DriftAccessor(tables: [Lessons])
class LessonDao extends DatabaseAccessor<AppDatabase> with _$LessonDaoMixin {
  LessonDao(AppDatabase db) : super(db);

  // Get all lessons for a path
  Future<List<Lesson>> getLessonsByPath(String pathId) async {
    return await (select(lessons)
          ..where((lesson) => lesson.pathId.equals(pathId))
          ..orderBy([(lesson) => OrderingTerm.asc(lesson.orderIndex)]))
        .get();
  }

  // Get lesson by ID
  Future<Lesson?> getLessonById(String id) async {
    return await (select(lessons)
          ..where((lesson) => lesson.id.equals(id)))
        .getSingleOrNull();
  }

  // Get next lesson in path
  Future<Lesson?> getNextLesson(String pathId, int currentOrderIndex) async {
    return await (select(lessons)
          ..where((lesson) => 
              lesson.pathId.equals(pathId) & 
              lesson.orderIndex.isBiggerThanValue(currentOrderIndex))
          ..orderBy([(lesson) => OrderingTerm.asc(lesson.orderIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  // Get previous lesson in path
  Future<Lesson?> getPreviousLesson(String pathId, int currentOrderIndex) async {
    return await (select(lessons)
          ..where((lesson) => 
              lesson.pathId.equals(pathId) & 
              lesson.orderIndex.isSmallerThanValue(currentOrderIndex))
          ..orderBy([(lesson) => OrderingTerm.desc(lesson.orderIndex)])
          ..limit(1))
        .getSingleOrNull();
  }

  // Get lessons by tag
  Future<List<Lesson>> getLessonsByTag(String tag) async {
    return await (select(lessons)
          ..where((lesson) => lesson.tags.contains(tag)))
        .get();
  }

  // Insert lesson
  Future<void> insertLesson(model.Lesson lesson) async {
    final lessonData = Lesson(
      id: lesson.id,
      pathId: lesson.pathId,
      name: lesson.name,
      description: lesson.description,
      orderIndex: lesson.orderIndex,
      estimatedMinutes: lesson.estimatedMinutes,
      prerequisites: lesson.prerequisitesJson,
      tags: lesson.tagsJson,
      createdAt: lesson.createdAt,
      updatedAt: lesson.updatedAt,
    );

    await into(lessons).insert(lessonData);
  }

  // Update lesson
  Future<void> updateLesson(model.Lesson lesson) async {
    final lessonData = Lesson(
      id: lesson.id,
      pathId: lesson.pathId,
      name: lesson.name,
      description: lesson.description,
      orderIndex: lesson.orderIndex,
      estimatedMinutes: lesson.estimatedMinutes,
      prerequisites: lesson.prerequisitesJson,
      tags: lesson.tagsJson,
      createdAt: lesson.createdAt,
      updatedAt: lesson.updatedAt,
    );

    await update(lessons).replace(lessonData);
  }

  // Delete lesson
  Future<void> deleteLesson(String id) async {
    await (delete(lessons)..where((lesson) => lesson.id.equals(id))).go();
  }

  // Upsert lesson
  Future<void> upsertLesson(model.Lesson lesson) async {
    final lessonData = Lesson(
      id: lesson.id,
      pathId: lesson.pathId,
      name: lesson.name,
      description: lesson.description,
      orderIndex: lesson.orderIndex,
      estimatedMinutes: lesson.estimatedMinutes,
      prerequisites: lesson.prerequisitesJson,
      tags: lesson.tagsJson,
      createdAt: lesson.createdAt,
      updatedAt: lesson.updatedAt,
    );

    await into(lessons).insertOnConflictUpdate(lessonData);
  }

  // Convert Drift data to model
  model.Lesson toModel(Lesson data) {
    return model.Lesson.fromDrift(
      id: data.id,
      pathId: data.pathId,
      name: data.name,
      description: data.description,
      orderIndex: data.orderIndex,
      estimatedMinutes: data.estimatedMinutes,
      prerequisitesJson: data.prerequisites,
      tagsJson: data.tags,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  // Get lessons by path as models
  Future<List<model.Lesson>> getLessonsByPathAsModels(String pathId) async {
    final lessonData = await getLessonsByPath(pathId);
    return lessonData.map((lesson) => toModel(lesson)).toList();
  }

  // Get lesson by ID as model
  Future<model.Lesson?> getLessonByIdAsModel(String id) async {
    final lessonData = await getLessonById(id);
    return lessonData != null ? toModel(lessonData) : null;
  }

  // Get next lesson as model
  Future<model.Lesson?> getNextLessonAsModel(String pathId, int currentOrderIndex) async {
    final lessonData = await getNextLesson(pathId, currentOrderIndex);
    return lessonData != null ? toModel(lessonData) : null;
  }

  // Get lessons that depend on this lesson (have it as prerequisite)
  Future<List<model.Lesson>> getDependentLessons(String lessonId) async {
    final allLessons = await select(lessons).get();
    final dependentLessons = <Lesson>[];
    
    for (final lesson in allLessons) {
      final prerequisites = List<String>.from(jsonDecode(lesson.prerequisites) as List);
      if (prerequisites.contains(lessonId)) {
        dependentLessons.add(lesson);
      }
    }
    
    return dependentLessons.map((lesson) => toModel(lesson)).toList();
  }
}