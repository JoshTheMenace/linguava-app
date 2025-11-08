import 'package:fsrs/fsrs.dart';
import '../data/vocabulary_data.dart';
import '../models/learning_item.dart';
import '../services/fsrs_service.dart';

/// Repository for managing vocabulary and their FSRS cards
class VocabularyRepository {
  final FSRSService _fsrsService;
  final Map<String, Map<String, dynamic>> _vocabulary = {};
  bool _isInitialized = false;

  VocabularyRepository(this._fsrsService);

  /// Initialize all vocabulary words with FSRS cards
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('Initializing vocabulary repository...');

    // Initialize FSRS service (loads cards from storage)
    await _fsrsService.initialize();

    // Load all words from vocabulary data
    for (var wordData in VocabularyData.getAllWords()) {
      final word = wordData['word'] as String;
      _vocabulary[word] = wordData;

      // Create FSRS card for each word if it doesn't exist
      if (!_fsrsService.hasCard(word)) {
        await _fsrsService.createCard(word);
        print('Created FSRS card for: $word');
      }
    }

    _isInitialized = true;
    print('Vocabulary repository initialized with ${_vocabulary.length} words');
  }

  /// Get vocabulary data for a specific word
  Map<String, dynamic>? getVocabularyData(String word) {
    return _vocabulary[word];
  }

  /// Get all vocabulary words
  List<String> getAllWords() {
    return _vocabulary.keys.toList();
  }

  /// Get the next batch of cards to study (due cards + new cards)
  /// [limit] - Maximum number of cards to return
  Future<List<Map<String, dynamic>>> getCardsToStudy({int limit = 10}) async {
    await initialize();

    final now = DateTime.now();
    final cardsToStudy = <Map<String, dynamic>>[];

    // Get all cards with their due dates
    final allCards = _fsrsService.getAllCards();
    final wordCards = <_WordCard>[];

    for (var entry in allCards.entries) {
      final word = entry.key;
      final card = entry.value;
      final vocabData = _vocabulary[word];

      if (vocabData != null) {
        wordCards.add(_WordCard(
          word: word,
          card: card,
          vocabData: vocabData,
          isDue: card.due.isBefore(now),
        ));
      }
    }

    // Sort by due date (most overdue first)
    wordCards.sort((a, b) => a.card.due.compareTo(b.card.due));

    // Take the requested number of cards
    final selectedCards = wordCards.take(limit).toList();

    // Convert to study format
    for (var wordCard in selectedCards) {
      cardsToStudy.add({
        'word': wordCard.word,
        'hiragana': wordCard.vocabData['hiragana'],
        'romaji': wordCard.vocabData['romaji'],
        'meaning': wordCard.vocabData['meaning'],
        'example': wordCard.vocabData['example'],
        'exampleMeaning': wordCard.vocabData['exampleMeaning'],
        'isDue': wordCard.isDue,
        'dueDate': wordCard.card.due.toIso8601String(),
      });
    }

    return cardsToStudy;
  }

  /// Get cards that are currently due for review
  Future<List<Map<String, dynamic>>> getDueCards() async {
    await initialize();

    final dueCards = <Map<String, dynamic>>[];
    final now = DateTime.now();

    final allCards = _fsrsService.getAllCards();

    for (var entry in allCards.entries) {
      final word = entry.key;
      final card = entry.value;
      final vocabData = _vocabulary[word];

      if (vocabData != null && card.due.isBefore(now)) {
        dueCards.add({
          'word': word,
          'hiragana': vocabData['hiragana'],
          'romaji': vocabData['romaji'],
          'meaning': vocabData['meaning'],
          'example': vocabData['example'],
          'exampleMeaning': vocabData['exampleMeaning'],
          'dueDate': card.due.toIso8601String(),
        });
      }
    }

    // Sort by due date (most overdue first)
    dueCards.sort((a, b) {
      final dateA = DateTime.parse(a['dueDate'] as String);
      final dateB = DateTime.parse(b['dueDate'] as String);
      return dateA.compareTo(dateB);
    });

    return dueCards;
  }

  /// Update a card after review
  /// [word] - The Japanese word
  /// [rating] - User's performance rating
  Future<bool> reviewCard(String word, Rating rating) async {
    final result = await _fsrsService.reviewCard(word, rating);
    if (result != null) {
      print('Updated card for "$word" with rating: ${rating.toString()}');
      print('Next review: ${result.card.due}');
      return true;
    }
    return false;
  }

  /// Get statistics about the vocabulary
  Map<String, dynamic> getStats() {
    final totalWords = _vocabulary.length;
    final dueCount = _fsrsService.dueCardsCount;

    return {
      'totalWords': totalWords,
      'dueCards': dueCount,
      'learned': totalWords - dueCount,
    };
  }

  /// Check if repository is initialized
  bool get isInitialized => _isInitialized;

  /// Get total word count
  int get totalWords => _vocabulary.length;
}

/// Helper class for sorting cards
class _WordCard {
  final String word;
  final Card card;
  final Map<String, dynamic> vocabData;
  final bool isDue;

  _WordCard({
    required this.word,
    required this.card,
    required this.vocabData,
    required this.isDue,
  });
}
