import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Database initialization provider
final databaseInitializationProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseProvider);
  // Database is automatically initialized when accessed
  // This provider can be used to ensure database is ready
  return;
});