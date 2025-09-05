import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'daos/deck_dao.dart';
import 'daos/flashcard_dao.dart';
import 'daos/study_card_dao.dart';
import 'daos/review_log_dao.dart';

part 'database.g.dart';

// Table definitions
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text()();
  TextColumn get language => text()();
  TextColumn get difficulty => text()();
  TextColumn get creatorId => text()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Flashcards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class FlashcardTags extends Table {
  TextColumn get flashcardId => text().references(Flashcards, #id, onDelete: KeyAction.cascade)();
  TextColumn get tag => text()();
  
  @override
  Set<Column> get primaryKey => {flashcardId, tag};
}

class StudyCards extends Table {
  TextColumn get flashcardId => text().references(Flashcards, #id, onDelete: KeyAction.cascade)();
  
  // FSRS Card data (stored as JSON)
  TextColumn get fsrsCardData => text()();
  
  // Additional tracking data
  BoolColumn get isNew => boolean().withDefault(const Constant(true))();
  BoolColumn get isLearning => boolean().withDefault(const Constant(false))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  RealColumn get difficulty => real().withDefault(const Constant(5.0))();
  RealColumn get stability => real().withDefault(const Constant(1.0))();
  IntColumn get daysUntilReview => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewDate => dateTime().nullable()();
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
  RealColumn get easeFactor => real().nullable()();
  IntColumn get interval => integer().nullable()();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {flashcardId};
}

class ReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get flashcardId => text().references(Flashcards, #id, onDelete: KeyAction.cascade)();
  IntColumn get rating => integer()(); // 1=again, 2=hard, 3=good, 4=easy
  IntColumn get state => integer()(); // FSRS state before review
  DateTimeColumn get reviewTime => dateTime()();
  IntColumn get reviewDuration => integer().nullable()(); // milliseconds
  RealColumn get difficultyBefore => real()();
  RealColumn get difficultyAfter => real()();
  RealColumn get stabilityBefore => real()();
  RealColumn get stabilityAfter => real()();
  DateTimeColumn get createdAt => dateTime()();
}

class StudySessionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deckId => text().references(Decks, #id, onDelete: KeyAction.cascade)();
  IntColumn get cardsStudied => integer()();
  IntColumn get correctAnswers => integer()();
  IntColumn get duration => integer()(); // seconds
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [
  Decks,
  Flashcards, 
  FlashcardTags,
  StudyCards,
  ReviewLogs,
  StudySessionsTable,
], daos: [
  DeckDao,
  FlashcardDao,
  StudyCardDao,
  ReviewLogDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future schema migrations here
    },
  );

  // DAO getters
  DeckDao get deckDao => DeckDao(this);
  FlashcardDao get flashcardDao => FlashcardDao(this);
  StudyCardDao get studyCardDao => StudyCardDao(this);
  ReviewLogDao get reviewLogDao => ReviewLogDao(this);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'linguava_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}