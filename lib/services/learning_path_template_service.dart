import '../models/learning_path.dart' as models;
import '../models/lesson.dart' as models;
import '../database/database.dart';

class LearningPathTemplateService {
  final AppDatabase _database;

  LearningPathTemplateService(this._database);

  // Initialize all template learning paths
  Future<void> initializeAllTemplates() async {
    await initializeJLPTN5Template();
    // Add more templates here in the future
    // await initializeSpanishBasicsTemplate();
    // await initializeFrenchBasicsTemplate();
  }

  // JLPT N5 Template
  Future<void> initializeJLPTN5Template() async {
    const pathId = 'jlpt-n5-path';
    
    print('Checking if JLPT N5 path exists...');
    // Check if path already exists
    final existingPath = await _database.learningPathDao.getPathById(pathId);
    if (existingPath != null) {
      print('JLPT N5 path already exists, skipping creation');
      return;
    }
    
    print('Creating new JLPT N5 path...');

    final now = DateTime.now();

    // Create the learning path
    final jlptN5Path = models.LearningPath(
      id: pathId,
      name: 'JLPT N5 Complete Course',
      description: 'Master Japanese fundamentals with this comprehensive JLPT N5 course. Learn hiragana, katakana, essential kanji, basic grammar patterns, and everyday vocabulary through structured lessons.',
      language: 'Japanese',
      level: 'Beginner',
      category: 'Exam Preparation',
      imageUrl: null,
      estimatedHours: 80,
      totalLessons: 20,
      isOfficial: true,
      createdAt: now,
      updatedAt: now,
    );

    await _database.learningPathDao.insertPath(jlptN5Path);

    // Create lessons for the JLPT N5 path
    final lessons = _createJLPTN5Lessons(pathId, now);
    print('About to insert ${lessons.length} lessons');
    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      try {
        await _database.lessonDao.insertLesson(lesson);
        print('Inserted lesson ${i + 1}: ${lesson.name}');
      } catch (error) {
        print('Error inserting lesson ${lesson.name}: $error');
      }
    }
    
    print('Learning path created: ${jlptN5Path.name} with ${lessons.length} lessons');
  }

  List<models.Lesson> _createJLPTN5Lessons(String pathId, DateTime now) {
    return [
      // === FOUNDATION LESSONS ===
      models.Lesson(
        id: 'jlpt-n5-lesson-01',
        pathId: pathId,
        name: 'Basic Greetings',
        description: 'Learn essential Japanese greetings and polite expressions used in daily conversations.',
        orderIndex: 0,
        estimatedMinutes: 45,
        prerequisites: [],
        tags: ['greetings', 'politeness', 'daily-conversation'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-02',
        pathId: pathId,
        name: 'Self Introduction',
        description: 'Master the art of introducing yourself in Japanese, including name, nationality, and occupation.',
        orderIndex: 1,
        estimatedMinutes: 50,
        prerequisites: ['jlpt-n5-lesson-01'],
        tags: ['self-introduction', 'personal-information', 'conversation'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-03',
        pathId: pathId,
        name: 'Numbers & Time',
        description: 'Learn Japanese numbers, counting, and how to tell time.',
        orderIndex: 2,
        estimatedMinutes: 60,
        prerequisites: ['jlpt-n5-lesson-02'],
        tags: ['numbers', 'time', 'counting', 'dates'],
        createdAt: now,
        updatedAt: now,
      ),

      // === CORE GRAMMAR FOUNDATIONS ===
      models.Lesson(
        id: 'jlpt-n5-lesson-04',
        pathId: pathId,
        name: 'Particles は, が, を',
        description: 'Master the fundamental particles that form the backbone of Japanese sentences.',
        orderIndex: 3,
        estimatedMinutes: 55,
        prerequisites: ['jlpt-n5-lesson-03'],
        tags: ['particles', 'grammar', 'sentence-structure'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-05',
        pathId: pathId,
        name: 'です/である & Present Tense',
        description: 'Learn the copula and present tense forms in polite and casual speech.',
        orderIndex: 4,
        estimatedMinutes: 50,
        prerequisites: ['jlpt-n5-lesson-04'],
        tags: ['copula', 'present-tense', 'politeness-levels'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-06',
        pathId: pathId,
        name: 'Verb Groups & Dictionary Form',
        description: 'Understand the three verb groups and how to identify dictionary forms.',
        orderIndex: 5,
        estimatedMinutes: 65,
        prerequisites: ['jlpt-n5-lesson-05'],
        tags: ['verbs', 'verb-groups', 'dictionary-form'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-07',
        pathId: pathId,
        name: 'Past Tense & Negation',
        description: 'Learn how to express past actions and negative forms.',
        orderIndex: 6,
        estimatedMinutes: 55,
        prerequisites: ['jlpt-n5-lesson-06'],
        tags: ['past-tense', 'negation', 'verb-conjugation'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-08',
        pathId: pathId,
        name: 'Adjectives (い & な)',
        description: 'Master both types of Japanese adjectives and their conjugations.',
        orderIndex: 7,
        estimatedMinutes: 50,
        prerequisites: ['jlpt-n5-lesson-07'],
        tags: ['adjectives', 'i-adjectives', 'na-adjectives', 'conjugation'],
        createdAt: now,
        updatedAt: now,
      ),

      // === VOCABULARY BUILDING ===
      models.Lesson(
        id: 'jlpt-n5-lesson-09',
        pathId: pathId,
        name: 'Family & Relationships',
        description: 'Learn vocabulary for family members and relationship terms.',
        orderIndex: 8,
        estimatedMinutes: 40,
        prerequisites: ['jlpt-n5-lesson-08'],
        tags: ['family', 'relationships', 'vocabulary'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-10',
        pathId: pathId,
        name: 'Food & Dining',
        description: 'Essential vocabulary for food, drinks, and dining experiences.',
        orderIndex: 9,
        estimatedMinutes: 45,
        prerequisites: ['jlpt-n5-lesson-09'],
        tags: ['food', 'dining', 'restaurants', 'vocabulary'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-11',
        pathId: pathId,
        name: 'Shopping & Money',
        description: 'Learn how to shop, discuss prices, and handle money in Japanese.',
        orderIndex: 10,
        estimatedMinutes: 50,
        prerequisites: ['jlpt-n5-lesson-10'],
        tags: ['shopping', 'money', 'prices', 'transactions'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-12',
        pathId: pathId,
        name: 'Transportation & Directions',
        description: 'Navigate Japan with essential transportation and direction vocabulary.',
        orderIndex: 11,
        estimatedMinutes: 55,
        prerequisites: ['jlpt-n5-lesson-11'],
        tags: ['transportation', 'directions', 'travel', 'navigation'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-13',
        pathId: pathId,
        name: 'Daily Activities & Schedule',
        description: 'Express daily routines, activities, and time-related concepts.',
        orderIndex: 12,
        estimatedMinutes: 45,
        prerequisites: ['jlpt-n5-lesson-12'],
        tags: ['daily-activities', 'schedule', 'routine', 'time'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-14',
        pathId: pathId,
        name: 'Weather & Seasons',
        description: 'Discuss weather conditions and seasonal changes in Japanese.',
        orderIndex: 13,
        estimatedMinutes: 40,
        prerequisites: ['jlpt-n5-lesson-13'],
        tags: ['weather', 'seasons', 'climate', 'nature'],
        createdAt: now,
        updatedAt: now,
      ),

      // === ADVANCED CONCEPTS & KANJI ===
      models.Lesson(
        id: 'jlpt-n5-lesson-15',
        pathId: pathId,
        name: 'Essential Kanji (Part 1)',
        description: 'Learn the first set of essential kanji characters for JLPT N5.',
        orderIndex: 14,
        estimatedMinutes: 70,
        prerequisites: ['jlpt-n5-lesson-14'],
        tags: ['kanji', 'characters', 'reading', 'writing'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-16',
        pathId: pathId,
        name: 'Essential Kanji (Part 2)',
        description: 'Continue building your kanji foundation with more N5 characters.',
        orderIndex: 15,
        estimatedMinutes: 70,
        prerequisites: ['jlpt-n5-lesson-15'],
        tags: ['kanji', 'characters', 'reading', 'writing'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-17',
        pathId: pathId,
        name: 'て-form & Continuous Actions',
        description: 'Master the versatile て-form and express ongoing actions.',
        orderIndex: 16,
        estimatedMinutes: 60,
        prerequisites: ['jlpt-n5-lesson-16'],
        tags: ['te-form', 'continuous-actions', 'verb-forms'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-18',
        pathId: pathId,
        name: 'Desire & Ability (たい, できる)',
        description: 'Express wants, desires, and abilities in Japanese.',
        orderIndex: 17,
        estimatedMinutes: 50,
        prerequisites: ['jlpt-n5-lesson-17'],
        tags: ['desire', 'ability', 'tai-form', 'dekiru'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-19',
        pathId: pathId,
        name: 'Comparison & Quantity',
        description: 'Learn to compare things and express quantities and amounts.',
        orderIndex: 18,
        estimatedMinutes: 55,
        prerequisites: ['jlpt-n5-lesson-18'],
        tags: ['comparison', 'quantity', 'more-than', 'less-than'],
        createdAt: now,
        updatedAt: now,
      ),
      
      models.Lesson(
        id: 'jlpt-n5-lesson-20',
        pathId: pathId,
        name: 'JLPT N5 Review & Practice',
        description: 'Comprehensive review of all N5 concepts with practice exercises.',
        orderIndex: 19,
        estimatedMinutes: 90,
        prerequisites: ['jlpt-n5-lesson-19'],
        tags: ['review', 'practice', 'comprehensive', 'exam-prep'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Future template for Spanish basics
  Future<void> initializeSpanishBasicsTemplate() async {
    // TODO: Implement Spanish basics template
    const pathId = 'spanish-basics-path';
    
    final existingPath = await _database.learningPathDao.getPathById(pathId);
    if (existingPath != null) return;

    final now = DateTime.now();

    final spanishPath = models.LearningPath(
      id: pathId,
      name: 'Spanish Fundamentals',
      description: 'Master Spanish basics with essential grammar, vocabulary, and conversation skills.',
      language: 'Spanish',
      level: 'Beginner',
      category: 'General',
      imageUrl: null,
      estimatedHours: 60,
      totalLessons: 15,
      isOfficial: true,
      createdAt: now,
      updatedAt: now,
    );

    await _database.learningPathDao.insertPath(spanishPath);
    // Add Spanish lessons here...
  }

  // Future template for French basics
  Future<void> initializeFrenchBasicsTemplate() async {
    // TODO: Implement French basics template
    const pathId = 'french-basics-path';
    
    final existingPath = await _database.learningPathDao.getPathById(pathId);
    if (existingPath != null) return;

    final now = DateTime.now();

    final frenchPath = models.LearningPath(
      id: pathId,
      name: 'French Essentials',
      description: 'Build a solid foundation in French with core vocabulary and grammar.',
      language: 'French',
      level: 'Beginner',
      category: 'General',
      imageUrl: null,
      estimatedHours: 55,
      totalLessons: 12,
      isOfficial: true,
      createdAt: now,
      updatedAt: now,
    );

    await _database.learningPathDao.insertPath(frenchPath);
    // Add French lessons here...
  }

  // Utility method to check if templates are initialized
  Future<bool> areTemplatesInitialized() async {
    final jlptPath = await _database.learningPathDao.getPathById('jlpt-n5-path');
    return jlptPath != null;
  }

  // Method to get all available template paths
  Future<List<models.LearningPath>> getAvailableTemplates() async {
    final officialPaths = await _database.learningPathDao.getOfficialPaths();
    return officialPaths.map((path) => _database.learningPathDao.toModel(path)).toList();
  }

  // Method to force reinitialize templates (for debugging)
  Future<void> forceReinitializeTemplates() async {
    print('Force reinitializing all templates...');
    // Delete existing JLPT N5 path and lessons
    try {
      final existingPath = await _database.learningPathDao.getPathById('jlpt-n5-path');
      if (existingPath != null) {
        // Delete lessons first (due to foreign key constraints)
        final lessons = await _database.lessonDao.getLessonsByPath('jlpt-n5-path');
        for (final lesson in lessons) {
          await _database.lessonDao.deleteLesson(lesson.id);
        }
        // Then delete the path
        await _database.learningPathDao.deletePath('jlpt-n5-path');
        print('Deleted existing JLPT N5 template');
      }
    } catch (error) {
      print('Error deleting existing template: $error');
    }
    
    // Recreate templates
    await initializeAllTemplates();
  }
}