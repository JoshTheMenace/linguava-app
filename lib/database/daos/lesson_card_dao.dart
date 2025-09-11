import 'package:drift/drift.dart';
import '../database.dart';

part 'lesson_card_dao.g.dart';

@DriftAccessor(tables: [LessonCards, Flashcards])
class LessonCardDao extends DatabaseAccessor<AppDatabase> with _$LessonCardDaoMixin {
  LessonCardDao(AppDatabase db) : super(db);

  // Get all cards for a lesson
  Future<List<Flashcard>> getCardsForLesson(String lessonId) async {
    final query = select(flashcards).join([
      innerJoin(lessonCards, lessonCards.flashcardId.equalsExp(flashcards.id)),
    ])..where(lessonCards.lessonId.equals(lessonId))
      ..orderBy([OrderingTerm.asc(lessonCards.orderIndex)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(flashcards)).toList();
  }

  // Get card IDs for a lesson
  Future<List<String>> getCardIdsForLesson(String lessonId) async {
    final lessonCardRows = await (select(lessonCards)
          ..where((lc) => lc.lessonId.equals(lessonId))
          ..orderBy([(lc) => OrderingTerm.asc(lc.orderIndex)]))
        .get();

    return lessonCardRows.map((row) => row.flashcardId).toList();
  }

  // Get lessons for a card
  Future<List<String>> getLessonsForCard(String flashcardId) async {
    final lessonCardRows = await (select(lessonCards)
          ..where((lc) => lc.flashcardId.equals(flashcardId)))
        .get();

    return lessonCardRows.map((row) => row.lessonId).toList();
  }

  // Add card to lesson
  Future<void> addCardToLesson(String lessonId, String flashcardId, int orderIndex) async {
    final lessonCardData = LessonCard(
      lessonId: lessonId,
      flashcardId: flashcardId,
      orderIndex: orderIndex,
    );

    await into(lessonCards).insert(lessonCardData);
  }

  // Remove card from lesson
  Future<void> removeCardFromLesson(String lessonId, String flashcardId) async {
    await (delete(lessonCards)
          ..where((lc) => 
              lc.lessonId.equals(lessonId) & 
              lc.flashcardId.equals(flashcardId)))
        .go();
  }

  // Update card order in lesson
  Future<void> updateCardOrder(String lessonId, String flashcardId, int newOrderIndex) async {
    await (update(lessonCards)
          ..where((lc) => 
              lc.lessonId.equals(lessonId) & 
              lc.flashcardId.equals(flashcardId)))
        .write(LessonCardsCompanion(
          orderIndex: Value(newOrderIndex),
        ));
  }

  // Get card count for lesson
  Future<int> getCardCountForLesson(String lessonId) async {
    final countQuery = selectOnly(lessonCards)
      ..addColumns([lessonCards.flashcardId.count()])
      ..where(lessonCards.lessonId.equals(lessonId));

    final result = await countQuery.getSingle();
    return result.read(lessonCards.flashcardId.count()) ?? 0;
  }

  // Add multiple cards to lesson
  Future<void> addCardsToLesson(String lessonId, List<String> flashcardIds) async {
    final lessonCardData = flashcardIds.asMap().entries.map((entry) => 
      LessonCard(
        lessonId: lessonId,
        flashcardId: entry.value,
        orderIndex: entry.key,
      )
    ).toList();

    await batch((batch) {
      batch.insertAll(lessonCards, lessonCardData);
    });
  }

  // Remove all cards from lesson
  Future<void> removeAllCardsFromLesson(String lessonId) async {
    await (delete(lessonCards)..where((lc) => lc.lessonId.equals(lessonId))).go();
  }

  // Reorder all cards in lesson
  Future<void> reorderCardsInLesson(String lessonId, List<String> orderedFlashcardIds) async {
    await transaction(() async {
      // Remove all existing cards
      await removeAllCardsFromLesson(lessonId);
      
      // Add cards in new order
      await addCardsToLesson(lessonId, orderedFlashcardIds);
    });
  }

  // Check if card is in lesson
  Future<bool> isCardInLesson(String lessonId, String flashcardId) async {
    final lessonCard = await (select(lessonCards)
          ..where((lc) => 
              lc.lessonId.equals(lessonId) & 
              lc.flashcardId.equals(flashcardId)))
        .getSingleOrNull();

    return lessonCard != null;
  }

  // Get next card order index for lesson
  Future<int> getNextOrderIndex(String lessonId) async {
    final maxOrderQuery = selectOnly(lessonCards)
      ..addColumns([lessonCards.orderIndex.max()])
      ..where(lessonCards.lessonId.equals(lessonId));

    final result = await maxOrderQuery.getSingle();
    final maxOrder = result.read(lessonCards.orderIndex.max());
    return (maxOrder ?? -1) + 1;
  }
}