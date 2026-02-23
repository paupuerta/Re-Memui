import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_stats_model.dart';
import '../models/deck_stats_model.dart';

/// Remote data source for statistics
class StatisticsRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  StatisticsRemoteDataSource({
    required this.client,
    required this.baseUrl,
  });

  /// Get user statistics from API
  Future<UserStatsModel> getUserStats(String userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/users/$userId/stats'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserStatsModel.fromJson(json);
    } else {
      throw Exception('Failed to load user statistics: ${response.statusCode}');
    }
  }

  /// Get deck statistics from API
  Future<DeckStatsModel> getDeckStats(String deckId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/decks/$deckId/stats'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeckStatsModel.fromJson(json);
    } else {
      throw Exception('Failed to load deck statistics: ${response.statusCode}');
    }
  }
}
