import '../../domain/entities/user_stats.dart';
import '../../domain/entities/deck_stats.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../data_sources/statistics_remote_data_source.dart';

/// Implementation of statistics repository
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserStats> getUserStats(String userId) async {
    final model = await remoteDataSource.getUserStats(userId);
    return model.toEntity();
  }

  @override
  Future<DeckStats> getDeckStats(String deckId) async {
    final model = await remoteDataSource.getDeckStats(deckId);
    return model.toEntity();
  }
}
