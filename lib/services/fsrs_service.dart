import 'package:fsrs/fsrs.dart';
import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service to manage FSRS (Free Spaced Repetition Scheduler) for learning items
class FSRSService {
  final Scheduler _scheduler;
  final Map<String, Card> _cards = {};
  final StreamController<int> _dueCardsController = StreamController<int>.broadcast();
  Database? _database;
  bool _isInitialized = false;

  FSRSService() : _scheduler = Scheduler();

  /// Initialize the service by loading cards from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _initDatabase();
    await _loadCardsFromStorage();
    _isInitialized = true;
  }

  /// Initialize the database
  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'linguava.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE fsrs_cards (
            id TEXT PRIMARY KEY,
            card_data TEXT NOT NULL
          )
        ''');
        print('Created fsrs_cards table');
      },
    );
    print('Database initialized');
  }

  /// Stream of due cards count
  Stream<int> get dueCardsStream => _dueCardsController.stream;

  /// Get current count of cards due for review
  int get dueCardsCount {
    final now = DateTime.now();
    return _cards.values.where((card) => card.due.isBefore(now)).length;
  }

  /// Get total number of cards
  int get totalCards => _cards.length;

  /// Create a new learning card
  /// [id] - Unique identifier for the card (e.g., "word_こんにちは")
  Future<Card> createCard(String id) async {
    if (_cards.containsKey(id)) {
      return _cards[id]!;
    }

    // Create a new FSRS card
    final card = await Card.create();
    _cards[id] = card;
    _notifyDueCardsChanged();
    await _saveCardsToStorage();
    return card;
  }

  /// Review a card with a rating
  /// [id] - Card identifier
  /// [rating] - User's rating (Again, Hard, Good, Easy)
  /// Returns the updated card and review log
  Future<({Card card, ReviewLog reviewLog})?> reviewCard(
    String id,
    Rating rating,
  ) async {
    final card = _cards[id];
    if (card == null) return null;

    // Schedule the next review
    final result = _scheduler.reviewCard(card, rating);

    // Update the card in storage
    _cards[id] = result.card;
    _notifyDueCardsChanged();
    await _saveCardsToStorage();

    return result;
  }

  /// Get a card by ID
  Card? getCard(String id) {
    return _cards[id];
  }

  /// Get all cards that are due for review
  List<MapEntry<String, Card>> getDueCards() {
    final now = DateTime.now();
    return _cards.entries
        .where((entry) => entry.value.due.isBefore(now))
        .toList();
  }

  /// Get all cards
  Map<String, Card> getAllCards() {
    return Map.from(_cards);
  }

  /// Check if a card exists
  bool hasCard(String id) {
    return _cards.containsKey(id);
  }

  /// Get the retrievability (recall probability) of a card
  /// Returns a value between 0 and 1
  double? getCardRetrievability(String id) {
    final card = _cards[id];
    if (card == null) return null;
    return _scheduler.getCardRetrievability(card);
  }

  /// Calculate study streak (simplified version)
  /// TODO: Implement proper streak tracking with persistent storage
  int getStudyStreak() {
    // This is a placeholder - proper implementation would require
    // storing review dates in persistent storage
    return 0;
  }

  /// Notify listeners about changes to due cards count
  void _notifyDueCardsChanged() {
    _dueCardsController.add(dueCardsCount);
  }

  /// Clear all cards (useful for testing)
  Future<void> clearAllCards() async {
    _cards.clear();
    _notifyDueCardsChanged();
    await _saveCardsToStorage();
  }

  /// Dispose of resources
  void dispose() {
    _dueCardsController.close();
    _database?.close();
  }

  /// Save cards to database
  Future<void> _saveCardsToStorage() async {
    if (_database == null) return;

    try {
      final batch = _database!.batch();

      for (var entry in _cards.entries) {
        final cardJson = jsonEncode(entry.value.toJson());
        batch.insert(
          'fsrs_cards',
          {'id': entry.key, 'card_data': cardJson},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      print('Saved ${_cards.length} cards to database');
    } catch (e) {
      print('Error saving cards to database: $e');
    }
  }

  /// Load cards from database
  Future<void> _loadCardsFromStorage() async {
    if (_database == null) return;

    try {
      final List<Map<String, dynamic>> maps = await _database!.query('fsrs_cards');

      for (var row in maps) {
        final id = row['id'] as String;
        final cardDataJson = row['card_data'] as String;
        final cardJson = jsonDecode(cardDataJson) as Map<String, dynamic>;
        _cards[id] = Card.fromJson(cardJson);
      }

      print('Loaded ${_cards.length} cards from database');
      _notifyDueCardsChanged();
    } catch (e) {
      print('Error loading cards from database: $e');
    }
  }
}
