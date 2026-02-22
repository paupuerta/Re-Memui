import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:re_mem_ui/core/network/network_providers.dart';
import 'package:re_mem_ui/features/cards/data/repositories/deck_repository_impl.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/deck_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/create_deck.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/get_decks.dart';

/// Provides the [DeckRepository] implementation.
final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepositoryImpl(ref.watch(apiClientProvider));
});

/// Provides the [GetDecks] use case.
final getDecksUseCaseProvider = Provider<GetDecks>((ref) {
  return GetDecks(ref.watch(deckRepositoryProvider));
});

/// Provides the [CreateDeck] use case.
final createDeckUseCaseProvider = Provider<CreateDeck>((ref) {
  return CreateDeck(ref.watch(deckRepositoryProvider));
});
