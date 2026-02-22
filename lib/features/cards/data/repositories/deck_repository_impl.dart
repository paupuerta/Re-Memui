import 'package:dio/dio.dart';
import 'package:re_mem_ui/core/network/api_client.dart';
import 'package:re_mem_ui/features/cards/domain/entities/deck.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/deck_repository.dart';

/// Remote implementation of [DeckRepository].
class DeckRepositoryImpl implements DeckRepository {
  const DeckRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Deck> createDeck({
    required String userId,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        '/users/$userId/decks',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );
      return Deck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<Deck>> getDecks(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/decks');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => Deck.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Deck> getDeckById(String deckId) async {
    try {
      final response = await _apiClient.get('/decks/$deckId');
      return Deck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<Deck> updateDeck({
    required String deckId,
    String? name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.put(
        '/decks/$deckId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return Deck.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> deleteDeck({
    required String userId,
    required String deckId,
  }) async {
    try {
      await _apiClient.delete('/users/$userId/decks/$deckId');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    return Exception('Network error: ${e.message}');
  }
}
