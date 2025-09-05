import '../services/database_service.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/fsrs_service.dart';

class DataSeeder {
  static final DatabaseService _databaseService = DatabaseService.instance;
  static final FSRSService _fsrsService = FSRSService();

  static Future<void> seedInitialData() async {
    try {
      final db = _databaseService.database;
      
      // Check if we already have data
      final existingDecks = await db.deckDao.getAllDecks();
      if (existingDecks.isNotEmpty) {
        print('Database already seeded');
        return;
      }

      print('Seeding initial data...');

      // Create a sample deck
      final deck = Deck(
        id: 'default-deck',
        name: 'Spanish Basics',
        description: 'Basic Spanish vocabulary and phrases',
        language: 'Spanish',
        difficulty: 'Beginner',
        creatorId: 'system',
        isPublic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.deckDao.upsertDeck(deck);

      // Create sample flashcards
      final flashcards = [
        Flashcard(
          id: '1',
          front: 'Hola',
          back: 'Hello (Spanish greeting)',
          tags: ['Spanish', 'Greetings', 'Basic'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
        ),
        Flashcard(
          id: '2',
          front: 'Gracias',
          back: 'Thank you',
          tags: ['Spanish', 'Politeness', 'Basic'],
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          updatedAt: DateTime.now(),
        ),
        Flashcard(
          id: '3',
          front: '¿Cómo está usted?',
          back: 'How are you? (formal)',
          tags: ['Spanish', 'Questions', 'Formal'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        ),
        Flashcard(
          id: '4',
          front: 'Por favor',
          back: 'Please',
          tags: ['Spanish', 'Politeness', 'Basic'],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now(),
        ),
        Flashcard(
          id: '5',
          front: 'Adiós',
          back: 'Goodbye',
          tags: ['Spanish', 'Farewells', 'Basic'],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ];

      // Insert flashcards and initialize study cards
      for (final flashcard in flashcards) {
        await db.flashcardDao.insertFlashcard(flashcard, deck.id);
        await _fsrsService.initializeCard(flashcard);
      }

      print('Database seeded successfully with ${flashcards.length} flashcards');
    } catch (e) {
      print('Error seeding database: $e');
    }
  }
}