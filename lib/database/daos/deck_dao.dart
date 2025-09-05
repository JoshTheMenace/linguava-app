import 'package:drift/drift.dart';
import '../database.dart';
import '../../models/deck.dart' as model;

part 'deck_dao.g.dart';

@DriftAccessor(tables: [Decks])
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(AppDatabase db) : super(db);

  // Get all decks
  Future<List<Deck>> getAllDecks() => select(decks).get();

  // Get deck by ID
  Future<Deck?> getDeckById(String id) => 
      (select(decks)..where((d) => d.id.equals(id))).getSingleOrNull();

  // Get public decks
  Future<List<Deck>> getPublicDecks() =>
      (select(decks)..where((d) => d.isPublic.equals(true))).get();

  // Get decks by creator
  Future<List<Deck>> getDecksByCreator(String creatorId) =>
      (select(decks)..where((d) => d.creatorId.equals(creatorId))).get();

  // Search decks by name or description
  Future<List<Deck>> searchDecks(String query) {
    final lowerQuery = query.toLowerCase();
    return (select(decks)
          ..where((d) => 
              d.name.lower().contains(lowerQuery) |
              d.description.lower().contains(lowerQuery)))
        .get();
  }

  // Insert or update deck
  Future<String> upsertDeck(model.Deck deck) async {
    final deckData = Deck(
      id: deck.id,
      name: deck.name,
      description: deck.description,
      language: deck.language,
      difficulty: deck.difficulty,
      creatorId: deck.creatorId,
      isPublic: deck.isPublic,
      createdAt: deck.createdAt,
      updatedAt: deck.updatedAt,
    );
    
    await into(decks).insertOnConflictUpdate(deckData);
    return deck.id;
  }

  // Delete deck
  Future<void> deleteDeck(String id) async {
    await (delete(decks)..where((d) => d.id.equals(id))).go();
  }

  // Get deck statistics
  Future<Map<String, int>> getDeckStats(String deckId) async {
    // This will be implemented with joins to get card counts
    final totalCards = await (attachedDatabase.flashcards.count(
      where: (f) => f.deckId.equals(deckId)
    )).getSingle();
    
    final studyCards = await (attachedDatabase.studyCards.count()).getSingle();
    
    return {
      'totalCards': totalCards,
      'studyCards': studyCards,
    };
  }
}