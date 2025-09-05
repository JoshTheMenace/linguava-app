import 'package:fsrs/fsrs.dart';
import '../models/study_card.dart';
import '../models/flashcard.dart';
import 'database_service.dart';

class FSRSService {
  late final Scheduler _scheduler;
  final DatabaseService _databaseService = DatabaseService.instance;

  FSRSService() {
    _scheduler = Scheduler();
  }

  /// Initialize a new card for first-time study
  Future<StudyCard> initializeCard(Flashcard flashcard) async {
    final fsrsCard = Card(cardId: int.parse(flashcard.id));
    
    final studyCard = StudyCard(
      flashcard: flashcard,
      fsrsCard: fsrsCard,
      isNew: true,
      isLearning: false,
      reviewCount: 0,
      difficulty: fsrsCard.difficulty ?? 5.0,
      stability: fsrsCard.stability ?? 1.0,
      daysUntilReview: 0,
      lastReviewDate: null,
      nextReviewDate: DateTime.now(),
    );

    // Save to database
    await _databaseService.database.studyCardDao.initializeStudyCard(flashcard.id, fsrsCard);
    
    return studyCard;
  }

  /// Process a card review and return updated card with next review schedule
  Future<StudyCard> reviewCard(StudyCard studyCard, StudyGrade grade) async {
    final rating = _gradeToRating(grade);
    final now = DateTime.now().toUtc();
    
    // Review the card using FSRS scheduler
    final result = _scheduler.reviewCard(studyCard.fsrsCard, rating);
    final updatedCard = result.card;
    
    // Calculate next review date
    final nextReviewDate = updatedCard.due;
    final daysUntilReview = nextReviewDate.difference(now).inDays;
    
    // Update card state based on rating and new state
    final isNew = updatedCard.state == State.learning && studyCard.isNew;
    final isLearning = updatedCard.state == State.learning || updatedCard.state == State.relearning;
    
    final updatedStudyCard = StudyCard(
      flashcard: studyCard.flashcard,
      fsrsCard: updatedCard,
      isNew: isNew,
      isLearning: isLearning,
      reviewCount: studyCard.reviewCount + 1,
      difficulty: updatedCard.difficulty ?? 5.0,
      stability: updatedCard.stability ?? 1.0,
      daysUntilReview: daysUntilReview > 0 ? daysUntilReview : 0,
      lastReviewDate: now,
      nextReviewDate: nextReviewDate,
      easeFactor: updatedCard.difficulty,
      interval: daysUntilReview,
      lapses: (updatedCard.toMap()['lapses'] as int?) ?? 0,
    );

    // Save to database
    await _databaseService.database.studyCardDao.upsertStudyCard(updatedStudyCard);

    // Log the review
    await _databaseService.database.reviewLogDao.logReview(
      flashcardId: studyCard.flashcard.id,
      rating: grade,
      stateBefore: studyCard.fsrsCard.state.index,
      reviewTime: now,
      difficultyBefore: studyCard.difficulty,
      difficultyAfter: updatedStudyCard.difficulty,
      stabilityBefore: studyCard.stability,
      stabilityAfter: updatedStudyCard.stability,
    );

    return updatedStudyCard;
  }

  /// Get next review times for all grade options
  Map<StudyGrade, String> getNextReviewTimes(StudyCard studyCard) {
    final now = DateTime.now().toUtc();
    
    // Get preview of what would happen with each rating
    final againResult = _scheduler.reviewCard(studyCard.fsrsCard, Rating.again);
    final hardResult = _scheduler.reviewCard(studyCard.fsrsCard, Rating.hard);
    final goodResult = _scheduler.reviewCard(studyCard.fsrsCard, Rating.good);
    final easyResult = _scheduler.reviewCard(studyCard.fsrsCard, Rating.easy);
    
    return {
      StudyGrade.again: _formatReviewTime(againResult.card.due, now),
      StudyGrade.hard: _formatReviewTime(hardResult.card.due, now),
      StudyGrade.good: _formatReviewTime(goodResult.card.due, now),
      StudyGrade.easy: _formatReviewTime(easyResult.card.due, now),
    };
  }

  /// Get cards that are due for review from database
  Future<List<StudyCard>> getDueCards({String? deckId, int? limit}) async {
    return await _databaseService.database.studyCardDao.getDueCards(deckId: deckId, limit: limit);
  }

  /// Get new cards that haven't been studied yet from database
  Future<List<StudyCard>> getNewCards({String? deckId, int? limit}) async {
    return await _databaseService.database.studyCardDao.getNewCards(deckId: deckId, limit: limit);
  }

  /// Get cards in learning phase from database
  Future<List<StudyCard>> getLearningCards({String? deckId}) async {
    return await _databaseService.database.studyCardDao.getLearningCards(deckId: deckId);
  }

  /// Get all study cards for a deck
  Future<List<StudyCard>> getStudyCardsByDeck(String deckId) async {
    return await _databaseService.database.studyCardDao.getStudyCardsByDeck(deckId);
  }

  /// Get study card by flashcard ID
  Future<StudyCard?> getStudyCard(String flashcardId) async {
    return await _databaseService.database.studyCardDao.getStudyCard(flashcardId);
  }

  /// Calculate retention rate for a set of cards
  double calculateRetention(List<StudyCard> cards) {
    if (cards.isEmpty) return 0.0;
    
    final reviewedCards = cards.where((card) => card.reviewCount > 0);
    if (reviewedCards.isEmpty) return 0.0;
    
    final totalReviews = reviewedCards.fold<int>(
      0, (sum, card) => sum + card.reviewCount
    );
    
    // This is a simplified calculation - in a real app, you'd track actual success/failure rates
    final averageDifficulty = reviewedCards.fold<double>(
      0, (sum, card) => sum + card.difficulty
    ) / reviewedCards.length;
    
    // Convert difficulty to estimated retention (inverse relationship)
    return (10 - averageDifficulty) / 10;
  }

  /// Get study statistics from database
  Future<Map<String, dynamic>> getStudyStatistics(String deckId) async {
    return await _databaseService.database.studyCardDao.getDeckStatistics(deckId);
  }

  /// Get review statistics
  Future<Map<String, dynamic>> getReviewStatistics({
    String? flashcardId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.database.reviewLogDao.getReviewStats(
      flashcardId: flashcardId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get daily review counts
  Future<Map<String, int>> getDailyReviewCounts(DateTime startDate, DateTime endDate) async {
    return await _databaseService.database.reviewLogDao.getDailyReviewCounts(startDate, endDate);
  }

  // Private helper methods

  Rating _gradeToRating(StudyGrade grade) {
    switch (grade) {
      case StudyGrade.again:
        return Rating.again;
      case StudyGrade.hard:
        return Rating.hard;
      case StudyGrade.good:
        return Rating.good;
      case StudyGrade.easy:
        return Rating.easy;
    }
  }

  String _formatReviewTime(DateTime reviewDate, DateTime now) {
    final difference = reviewDate.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '<1m';
    }
  }
}

/// Extension to add FSRS-specific methods to StudyCard
extension StudyCardExtension on StudyCard {
  /// Get the card status as a human-readable string
  String get cardStatus {
    if (isNew) return 'New';
    if (isLearning) return 'Learning';
    if (daysUntilReview <= 0) return 'Due';
    if (daysUntilReview <= 1) return 'Soon';
    return 'Scheduled';
  }

  /// Get next review text
  String get nextReviewText {
    if (isNew) return 'New card';
    if (nextReviewDate == null) return 'Not scheduled';
    
    final now = DateTime.now();
    final difference = nextReviewDate!.difference(now);
    
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Due now';
    }
  }

  /// Check if card is due for review
  bool get isDue {
    if (nextReviewDate == null) return isNew;
    return nextReviewDate!.isBefore(DateTime.now()) || 
           nextReviewDate!.isAtSameMomentAs(DateTime.now());
  }
}