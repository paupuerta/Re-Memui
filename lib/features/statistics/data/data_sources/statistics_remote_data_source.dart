import 'package:dio/dio.dart';
import '../models/user_stats_model.dart';
import '../models/deck_stats_model.dart';

/// Remote data source for statistics
class StatisticsRemoteDataSource {
  final Dio dio;

  StatisticsRemoteDataSource({
    required this.dio,
  });

  /// Get user statistics from API
  Future<UserStatsModel> getUserStats(String userId) async {
    final response = await dio.get('/api/v1/users/$userId/stats');

    if (response.statusCode == 200) {
      return UserStatsModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load user statistics: ${response.statusCode}');
    }
  }

  /// Get deck statistics from API
  Future<DeckStatsModel> getDeckStats(String deckId) async {
    final response = await dio.get('/api/v1/decks/$deckId/stats');

    if (response.statusCode == 200) {
      return DeckStatsModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load deck statistics: ${response.statusCode}');
    }
  }
}
