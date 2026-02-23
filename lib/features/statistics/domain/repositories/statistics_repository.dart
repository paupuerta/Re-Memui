import '../entities/user_stats.dart';
import '../entities/deck_stats.dart';

/// Repository interface for statistics
abstract class StatisticsRepository {
  /// Get statistics for a user
  Future<UserStats> getUserStats(String userId);

  /// Get statistics for a deck
  Future<DeckStats> getDeckStats(String deckId);
}
