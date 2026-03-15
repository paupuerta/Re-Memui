import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/features/cards/domain/entities/card.dart'
    as card_entity;
import 'package:re_mem_ui/features/cards/domain/entities/deck.dart';
import 'package:re_mem_ui/features/cards/domain/entities/review_result.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/card_providers.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/deck_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/get_decks.dart';
import 'package:re_mem_ui/features/cards/presentation/providers/deck_providers.dart';
import 'package:re_mem_ui/features/home/presentation/home_screen.dart';

class _FakeCardRepository implements CardRepository {
  @override
  Future<Either<Failure, List<card_entity.Card>>> getCards(
    String userId, {
    int? limit,
    int? offset,
    List<String>? excludeCardIds,
  }) async => const Right([]);

  @override
  Future<Either<Failure, List<card_entity.Card>>> getCardsByDeck(
    String deckId, {
    int? limit,
    int? offset,
    List<String>? excludeCardIds,
  }) async => const Right([]);

  @override
  Future<Either<Failure, card_entity.Card>> getCard(String cardId) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, card_entity.Card>> createCard({
    required String userId,
    required String question,
    required String answer,
    String? deckId,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, ReviewResult>> submitReview({
    required String cardId,
    required String userId,
    required String userAnswer,
  }) async => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteCard({
    required String userId,
    required String cardId,
  }) async => throw UnimplementedError();
}

class _FakeDeckRepository implements DeckRepository {
  @override
  Future<Deck> createDeck({
    required String userId,
    required String name,
    String? description,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteDeck({
    required String userId,
    required String deckId,
  }) async => throw UnimplementedError();

  @override
  Future<Deck> getDeckById(String deckId) async => throw UnimplementedError();

  @override
  Future<List<Deck>> getDecks(String userId) async => const [];

  @override
  Future<Deck> updateDeck({
    required String deckId,
    String? name,
    String? description,
  }) async => throw UnimplementedError();
}

void main() {
  group('HomeScreen', () {
    testWidgets('should display app title and welcome message', (tester) async {
      final fakeDeckUseCase = GetDecks(_FakeDeckRepository());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cardRepositoryProvider.overrideWithValue(_FakeCardRepository()),
            getDecksUseCaseProvider.overrideWithValue(fakeDeckUseCase),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ReMem'), findsOneWidget);
      expect(find.text('Welcome to ReMem'), findsOneWidget);
      expect(find.text('Your language learning companion'), findsOneWidget);
    });
  });
}
