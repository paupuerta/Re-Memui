import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/core/network/api_client.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';

/// Remote implementation of [CardRepository].
class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  AsyncResult<List<Card>> getCards(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/cards');
      final data = response.data as List<dynamic>;
      final cards = data
          .map((json) => Card(
                id: json['id'] as String,
                userId: json['user_id'] as String,
                question: json['question'] as String,
                answer: json['answer'] as String,
              ))
          .toList();
      return Right(cards);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  AsyncResult<Card> getCard(String cardId) async {
    try {
      final response = await _apiClient.get('/cards/$cardId');
      final json = response.data as Map<String, dynamic>;
      return Right(Card(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
      ));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  AsyncResult<Card> createCard({
    required String userId,
    required String question,
    required String answer,
  }) async {
    try {
      final response = await _apiClient.post(
        '/users/$userId/cards',
        data: {'question': question, 'answer': answer},
      );
      final json = response.data as Map<String, dynamic>;
      return Right(Card(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
      ));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    return switch (e.response?.statusCode) {
      404 => const NotFoundFailure(),
      400 => const ValidationFailure(),
      _ => e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout
          ? const NetworkFailure()
          : const ServerFailure(),
    };
  }
}
