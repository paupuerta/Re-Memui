import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:re_mem_ui/core/network/network_providers.dart';
import 'package:re_mem_ui/features/cards/data/repositories/card_repository_impl.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/create_card.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/get_cards.dart';

/// Provides the [CardRepository] implementation.
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(ref.watch(apiClientProvider));
});

/// Provides the [GetCardsUseCase].
final getCardsUseCaseProvider = Provider<GetCardsUseCase>((ref) {
  return GetCardsUseCase(ref.watch(cardRepositoryProvider));
});

/// Provides the [CreateCardUseCase].
final createCardUseCaseProvider = Provider<CreateCardUseCase>((ref) {
  return CreateCardUseCase(ref.watch(cardRepositoryProvider));
});
