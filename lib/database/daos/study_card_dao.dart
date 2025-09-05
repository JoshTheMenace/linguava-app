import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import '../database.dart';
import '../../models/study_card.dart' as model;
import '../../models/flashcard.dart' as flashcard_model;

part 'study_card_dao.g.dart';

@DriftAccessor(tables: [StudyCards, Flashcards, FlashcardTags])
class StudyCardDao extends DatabaseAccessor<AppDatabase> with _$StudyCardDaoMixin {
  StudyCardDao(AppDatabase db) : super(db);

  // Get all study cards for a deck
  Future<List<model.StudyCard>> getStudyCardsByDeck(String deckId) async {
    final query = select(studyCards).join([
      leftOuterJoin(flashcards, flashcards.id.equalsExp(studyCards.flashcardId)),
    ])..where(flashcards.deckId.equals(deckId));

    final rows = await query.get();
    final result = <model.StudyCard>[];

    for (final row in rows) {
      final studyCard = row.readTable(studyCards);
      final flashcard = row.readTable(flashcards);
      
      if (flashcard != null) {
        final tags = await _getFlashcardTags(flashcard.id);
        final modelFlashcard = _toModelFlashcard(flashcard, tags);
        final modelStudyCard = await _toModelStudyCard(studyCard, modelFlashcard);
        result.add(modelStudyCard);
      }
    }

    return result;
  }

  // Get study card by flashcard ID
  Future<model.StudyCard?> getStudyCard(String flashcardId) async {
    final studyCard = await (select(studyCards)
          ..where((s) => s.flashcardId.equals(flashcardId)))
        .getSingleOrNull();
    
    if (studyCard == null) return null;
    
    final flashcard = await (select(flashcards)
          ..where((f) => f.id.equals(flashcardId)))
        .getSingleOrNull();
    
    if (flashcard == null) return null;
    
    final tags = await _getFlashcardTags(flashcardId);
    final modelFlashcard = _toModelFlashcard(flashcard, tags);
    
    return await _toModelStudyCard(studyCard, modelFlashcard);
  }

  // Get due cards
  Future<List<model.StudyCard>> getDueCards({String? deckId, int? limit}) async {
    final now = DateTime.now();
    
    var query = select(studyCards).join([
      leftOuterJoin(flashcards, flashcards.id.equalsExp(studyCards.flashcardId)),
    ])..where(
        studyCards.nextReviewDate.isNull() | 
        studyCards.nextReviewDate.isSmallerOrEqualValue(now)
      );

    if (deckId != null) {
      query = query..where(flashcards.deckId.equals(deckId));
    }

    if (limit != null) {
      query = query..limit(limit);
    }

    final rows = await query.get();
    final result = <model.StudyCard>[];

    for (final row in rows) {
      final studyCard = row.readTable(studyCards);
      final flashcard = row.readTable(flashcards);
      
      if (flashcard != null) {
        final tags = await _getFlashcardTags(flashcard.id);
        final modelFlashcard = _toModelFlashcard(flashcard, tags);
        final modelStudyCard = await _toModelStudyCard(studyCard, modelFlashcard);
        result.add(modelStudyCard);
      }
    }

    return result;
  }

  // Get new cards
  Future<List<model.StudyCard>> getNewCards({String? deckId, int? limit}) async {
    var query = select(studyCards).join([
      leftOuterJoin(flashcards, flashcards.id.equalsExp(studyCards.flashcardId)),
    ])..where(studyCards.isNew.equals(true));

    if (deckId != null) {
      query = query..where(flashcards.deckId.equals(deckId));
    }

    if (limit != null) {
      query = query..limit(limit);
    }

    final rows = await query.get();
    final result = <model.StudyCard>[];

    for (final row in rows) {
      final studyCard = row.readTable(studyCards);
      final flashcard = row.readTable(flashcards);
      
      if (flashcard != null) {
        final tags = await _getFlashcardTags(flashcard.id);
        final modelFlashcard = _toModelFlashcard(flashcard, tags);
        final modelStudyCard = await _toModelStudyCard(studyCard, modelFlashcard);
        result.add(modelStudyCard);
      }
    }

    return result;
  }

  // Get learning cards
  Future<List<model.StudyCard>> getLearningCards({String? deckId}) async {
    var query = select(studyCards).join([
      leftOuterJoin(flashcards, flashcards.id.equalsExp(studyCards.flashcardId)),
    ])..where(studyCards.isLearning.equals(true));

    if (deckId != null) {
      query = query..where(flashcards.deckId.equals(deckId));
    }

    final rows = await query.get();
    final result = <model.StudyCard>[];

    for (final row in rows) {
      final studyCard = row.readTable(studyCards);
      final flashcard = row.readTable(flashcards);
      
      if (flashcard != null) {
        final tags = await _getFlashcardTags(flashcard.id);
        final modelFlashcard = _toModelFlashcard(flashcard, tags);
        final modelStudyCard = await _toModelStudyCard(studyCard, modelFlashcard);
        result.add(modelStudyCard);
      }
    }

    return result;
  }

  // Insert or update study card
  Future<void> upsertStudyCard(model.StudyCard studyCard) async {
    final fsrsCardJson = jsonEncode(studyCard.fsrsCard.toMap());
    
    final studyCardData = StudyCard(
      flashcardId: studyCard.flashcard.id,
      fsrsCardData: fsrsCardJson,
      isNew: studyCard.isNew,
      isLearning: studyCard.isLearning,
      reviewCount: studyCard.reviewCount,
      difficulty: studyCard.difficulty,
      stability: studyCard.stability,
      daysUntilReview: studyCard.daysUntilReview,
      lastReviewDate: studyCard.lastReviewDate,
      nextReviewDate: studyCard.nextReviewDate,
      easeFactor: studyCard.easeFactor,
      interval: studyCard.interval,
      lapses: studyCard.lapses ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await into(studyCards).insertOnConflictUpdate(studyCardData);
  }

  // Initialize study card from flashcard
  Future<void> initializeStudyCard(String flashcardId, fsrs.Card fsrsCard) async {
    final studyCardData = StudyCard(
      flashcardId: flashcardId,
      fsrsCardData: jsonEncode(fsrsCard.toMap()),
      isNew: true,
      isLearning: false,
      reviewCount: 0,
      difficulty: fsrsCard.difficulty ?? 5.0,
      stability: fsrsCard.stability ?? 1.0,
      daysUntilReview: 0,
      lastReviewDate: null,
      nextReviewDate: DateTime.now(),
      easeFactor: null,
      interval: null,
      lapses: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await into(studyCards).insert(studyCardData);
  }

  // Delete study card
  Future<void> deleteStudyCard(String flashcardId) async {
    await (delete(studyCards)..where((s) => s.flashcardId.equals(flashcardId))).go();
  }

  // Get study statistics for a deck
  Future<Map<String, dynamic>> getDeckStatistics(String deckId) async {
    // Total cards in deck
    final totalCards = await (select(flashcards)
          ..where((f) => f.deckId.equals(deckId)))
        .get()
        .then((rows) => rows.length);
    
    // Get all study cards for this deck
    final allStudyCards = await getStudyCardsByDeck(deckId);
    
    // Calculate statistics
    final newCards = allStudyCards.where((c) => c.isNew).length;
    final learningCards = allStudyCards.where((c) => c.isLearning).length;
    final now = DateTime.now();
    final dueCards = allStudyCards.where((c) => 
      c.nextReviewDate != null && 
      c.nextReviewDate!.isBefore(now) && 
      !c.isNew
    ).length;
    final reviewedCards = allStudyCards.where((c) => c.reviewCount > 0).length;
    final masteredCards = allStudyCards.where((c) => 
      c.reviewCount >= 3 && c.difficulty < 5.0
    ).length;

    return {
      'totalCards': totalCards,
      'newCards': newCards,
      'learningCards': learningCards,
      'dueCards': dueCards,
      'reviewedCards': reviewedCards,
      'masteredCards': masteredCards,
      'retention': reviewedCards > 0 ? masteredCards / reviewedCards : 0.0,
    };
  }

  // Helper methods
  Future<List<String>> _getFlashcardTags(String flashcardId) async {
    final tagRows = await (select(flashcardTags)
          ..where((t) => t.flashcardId.equals(flashcardId)))
        .get();
    
    return tagRows.map((t) => t.tag).toList();
  }

  flashcard_model.Flashcard _toModelFlashcard(Flashcard card, List<String> tags) {
    return flashcard_model.Flashcard(
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

  Future<model.StudyCard> _toModelStudyCard(StudyCard studyCard, flashcard_model.Flashcard flashcard) async {
    // Deserialize FSRS card data
    final fsrsCardMap = jsonDecode(studyCard.fsrsCardData) as Map<String, dynamic>;
    final fsrsCard = fsrs.Card.fromMap(fsrsCardMap);

    return model.StudyCard(
      flashcard: flashcard,
      fsrsCard: fsrsCard,
      isNew: studyCard.isNew,
      isLearning: studyCard.isLearning,
      reviewCount: studyCard.reviewCount,
      difficulty: studyCard.difficulty,
      stability: studyCard.stability,
      daysUntilReview: studyCard.daysUntilReview,
      lastReviewDate: studyCard.lastReviewDate,
      nextReviewDate: studyCard.nextReviewDate,
      easeFactor: studyCard.easeFactor,
      interval: studyCard.interval,
      lapses: studyCard.lapses,
    );
  }
}