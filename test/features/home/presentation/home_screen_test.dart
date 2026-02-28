import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart' as card_entity;
import 'package:re_mem_ui/features/cards/domain/entities/review_result.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/get_cards.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';
import 'package:re_mem_ui/features/home/presentation/home_screen.dart';

class _FakeCardRepository implements CardRepository {
  @override
  Future<Either<Failure, List<card_entity.Card>>> getCards(String userId) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<card_entity.Card>>> getCardsByDeck(String deckId) async =>
      const Right([]);

  @override
  Future<Either<Failure, card_entity.Card>> getCard(String cardId) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, card_entity.Card>> createCard({
    required String userId,
    required String question,
    required String answer,
    String? deckId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, ReviewResult>> submitReview({
    required String cardId,
    required String userId,
    required String userAnswer,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteCard({
    required String userId,
    required String cardId,
  }) async =>
      throw UnimplementedError();
}

void main() {
  group('HomeScreen', () {
    testWidgets('should display app title and welcome message',
        (tester) async {
      final fakeUseCase = GetCardsUseCase(_FakeCardRepository());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            getCardsUseCaseProvider.overrideWithValue(fakeUseCase),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ReMem'), findsOneWidget);
      expect(find.text('Welcome to ReMem'), findsOneWidget);
      expect(
        find.text('Your language learning companion'),
        findsOneWidget,
      );
    });
  });
}
