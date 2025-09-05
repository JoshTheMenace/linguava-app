import 'package:drift/drift.dart';
import '../database.dart';
import '../../models/study_card.dart' as model;

part 'review_log_dao.g.dart';

@DriftAccessor(tables: [ReviewLogs])
class ReviewLogDao extends DatabaseAccessor<AppDatabase> with _$ReviewLogDaoMixin {
  ReviewLogDao(AppDatabase db) : super(db);

  // Log a review
  Future<int> logReview({
    required String flashcardId,
    required model.StudyGrade rating,
    required int stateBefore,
    required DateTime reviewTime,
    int? reviewDuration,
    required double difficultyBefore,
    required double difficultyAfter,
    required double stabilityBefore,
    required double stabilityAfter,
  }) async {
    final reviewLog = ReviewLogsCompanion.insert(
      flashcardId: flashcardId,
      rating: _gradeToInt(rating),
      state: stateBefore,
      reviewTime: reviewTime,
      reviewDuration: Value(reviewDuration),
      difficultyBefore: difficultyBefore,
      difficultyAfter: difficultyAfter,
      stabilityBefore: stabilityBefore,
      stabilityAfter: stabilityAfter,
      createdAt: DateTime.now(),
    );

    return await into(reviewLogs).insert(reviewLog);
  }

  // Get review history for a flashcard
  Future<List<ReviewLog>> getReviewHistory(String flashcardId, {int? limit}) async {
    var query = select(reviewLogs)
      ..where((r) => r.flashcardId.equals(flashcardId))
      ..orderBy([(r) => OrderingTerm.desc(r.reviewTime)]);

    if (limit != null) {
      query = query..limit(limit);
    }

    return await query.get();
  }

  // Get review statistics for a time period
  Future<Map<String, dynamic>> getReviewStats({
    String? flashcardId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = select(reviewLogs);
    
    final conditions = <Expression<bool>>[];
    
    if (flashcardId != null) {
      conditions.add(reviewLogs.flashcardId.equals(flashcardId));
    }
    
    if (startDate != null) {
      conditions.add(reviewLogs.reviewTime.isBiggerOrEqualValue(startDate));
    }
    
    if (endDate != null) {
      conditions.add(reviewLogs.reviewTime.isSmallerOrEqualValue(endDate));
    }
    
    if (conditions.isNotEmpty) {
      query = query..where((r) => conditions.reduce((a, b) => a & b));
    }

    final reviews = await query.get();
    
    if (reviews.isEmpty) {
      return {
        'totalReviews': 0,
        'correctAnswers': 0,
        'accuracy': 0.0,
        'averageReviewTime': 0.0,
        'difficultyChange': 0.0,
        'stabilityChange': 0.0,
      };
    }

    final totalReviews = reviews.length;
    final correctAnswers = reviews.where((r) => r.rating >= 3).length; // Good or Easy
    final accuracy = correctAnswers / totalReviews;
    
    final reviewTimes = reviews
        .where((r) => r.reviewDuration != null)
        .map((r) => r.reviewDuration!)
        .toList();
    
    final averageReviewTime = reviewTimes.isNotEmpty 
        ? reviewTimes.reduce((a, b) => a + b) / reviewTimes.length 
        : 0.0;

    final difficultyChange = reviews.isNotEmpty
        ? reviews.map((r) => r.difficultyAfter - r.difficultyBefore)
            .reduce((a, b) => a + b) / reviews.length
        : 0.0;

    final stabilityChange = reviews.isNotEmpty
        ? reviews.map((r) => r.stabilityAfter - r.stabilityBefore)
            .reduce((a, b) => a + b) / reviews.length
        : 0.0;

    return {
      'totalReviews': totalReviews,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'averageReviewTime': averageReviewTime,
      'difficultyChange': difficultyChange,
      'stabilityChange': stabilityChange,
    };
  }

  // Get daily review counts for a date range
  Future<Map<String, int>> getDailyReviewCounts(DateTime startDate, DateTime endDate) async {
    final reviews = await (select(reviewLogs)
          ..where((r) => 
              r.reviewTime.isBiggerOrEqualValue(startDate) &
              r.reviewTime.isSmallerOrEqualValue(endDate)))
        .get();

    final dailyCounts = <String, int>{};
    
    for (final review in reviews) {
      final dateKey = review.reviewTime.toIso8601String().substring(0, 10); // YYYY-MM-DD
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }

    return dailyCounts;
  }

  // Delete old review logs (for cleanup)
  Future<int> deleteOldReviews(DateTime before) async {
    return await (delete(reviewLogs)
          ..where((r) => r.createdAt.isSmallerThanValue(before)))
        .go();
  }

  // Helper method to convert StudyGrade to int
  int _gradeToInt(model.StudyGrade grade) {
    switch (grade) {
      case model.StudyGrade.again:
        return 1;
      case model.StudyGrade.hard:
        return 2;
      case model.StudyGrade.good:
        return 3;
      case model.StudyGrade.easy:
        return 4;
    }
  }
}