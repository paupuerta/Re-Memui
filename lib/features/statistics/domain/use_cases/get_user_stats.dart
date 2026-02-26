import '../entities/user_stats.dart';
import '../repositories/statistics_repository.dart';

/// Use case for getting user statistics
class GetUserStats {
  final StatisticsRepository repository;

  GetUserStats(this.repository);

  Future<UserStats> call(String userId) async {
    return await repository.getUserStats(userId);
  }
}
