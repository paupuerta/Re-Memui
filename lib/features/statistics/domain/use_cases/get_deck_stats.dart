import '../entities/deck_stats.dart';
import '../repositories/statistics_repository.dart';

/// Use case for getting deck statistics
class GetDeckStats {
  final StatisticsRepository repository;

  GetDeckStats(this.repository);

  Future<DeckStats> call(String deckId) async {
    return await repository.getDeckStats(deckId);
  }
}
