import 'package:drift/drift.dart';
import '../database.dart';
import '../../models/flashcard.dart' as model;

part 'flashcard_dao.g.dart';

@DriftAccessor(tables: [Flashcards, FlashcardTags])
class FlashcardDao extends DatabaseAccessor<AppDatabase> with _$FlashcardDaoMixin {
  FlashcardDao(AppDatabase db) : super(db);

  // Get all flashcards for a deck
  Future<List<model.Flashcard>> getFlashcardsByDeck(String deckId) async {
    final cards = await (select(flashcards)
          ..where((f) => f.deckId.equals(deckId)))
        .get();
    
    // Get tags for each card
    final result = <model.Flashcard>[];
    for (final card in cards) {
      final tags = await getFlashcardTags(card.id);
      result.add(_toModelFlashcard(card, tags));
    }
    
    return result;
  }

  // Get flashcard by ID with tags
  Future<model.Flashcard?> getFlashcardById(String id) async {
    final card = await (select(flashcards)
          ..where((f) => f.id.equals(id)))
        .getSingleOrNull();
    
    if (card == null) return null;
    
    final tags = await getFlashcardTags(id);
    return _toModelFlashcard(card, tags);
  }

  // Get tags for a flashcard
  Future<List<String>> getFlashcardTags(String flashcardId) async {
    final tagRows = await (select(flashcardTags)
          ..where((t) => t.flashcardId.equals(flashcardId)))
        .get();
    
    return tagRows.map((t) => t.tag).toList();
  }

  // Insert or update flashcard with tags
  Future<String> upsertFlashcard(model.Flashcard flashcard) async {
    return await transaction(() async {
      // Insert/update the flashcard
      final flashcardData = Flashcard(
        id: flashcard.id,
        deckId: '', // This method shouldn't be used without deckId - use insertFlashcard instead
        front: flashcard.front,
        back: flashcard.back,
        imageUrl: flashcard.imageUrl,
        audioUrl: flashcard.audioUrl,
        createdAt: flashcard.createdAt,
        updatedAt: flashcard.updatedAt,
      );
      
      await into(flashcards).insertOnConflictUpdate(flashcardData);
      
      // Delete existing tags
      await (delete(flashcardTags)
            ..where((t) => t.flashcardId.equals(flashcard.id)))
          .go();
      
      // Insert new tags
      for (final tag in flashcard.tags) {
        await into(flashcardTags).insert(FlashcardTag(
          flashcardId: flashcard.id,
          tag: tag,
        ));
      }
      
      return flashcard.id;
    });
  }

  // Insert flashcard with deck ID
  Future<String> insertFlashcard(model.Flashcard flashcard, String deckId) async {
    return await transaction(() async {
      final flashcardData = Flashcard(
        id: flashcard.id,
        deckId: deckId,
        front: flashcard.front,
        back: flashcard.back,
        imageUrl: flashcard.imageUrl,
        audioUrl: flashcard.audioUrl,
        createdAt: flashcard.createdAt,
        updatedAt: flashcard.updatedAt,
      );
      
      await into(flashcards).insert(flashcardData);
      
      // Insert tags
      for (final tag in flashcard.tags) {
        await into(flashcardTags).insert(FlashcardTag(
          flashcardId: flashcard.id,
          tag: tag,
        ));
      }
      
      return flashcard.id;
    });
  }

  // Delete flashcard
  Future<void> deleteFlashcard(String id) async {
    await transaction(() async {
      await (delete(flashcardTags)..where((t) => t.flashcardId.equals(id))).go();
      await (delete(flashcards)..where((f) => f.id.equals(id))).go();
    });
  }

  // Search flashcards
  Future<List<model.Flashcard>> searchFlashcards(String query, {String? deckId}) async {
    final lowerQuery = query.toLowerCase();
    
    var selectQuery = select(flashcards)
      ..where((f) => 
          f.front.lower().contains(lowerQuery) |
          f.back.lower().contains(lowerQuery));
    
    if (deckId != null) {
      selectQuery = selectQuery..where((f) => f.deckId.equals(deckId));
    }
    
    final cards = await selectQuery.get();
    
    final result = <model.Flashcard>[];
    for (final card in cards) {
      final tags = await getFlashcardTags(card.id);
      result.add(_toModelFlashcard(card, tags));
    }
    
    return result;
  }

  // Helper method to convert database flashcard to model
  model.Flashcard _toModelFlashcard(Flashcard card, List<String> tags) {
    return model.Flashcard(
      id: card.id,
      front: card.front,
      back: card.back,
      imageUrl: card.imageUrl,
      audioUrl: card.audioUrl,
      tags: tags,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
    );
  }
}