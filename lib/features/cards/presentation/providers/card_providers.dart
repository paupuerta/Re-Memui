import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:re_mem_ui/core/network/network_providers.dart';
import 'package:re_mem_ui/features/cards/data/repositories/card_repository_impl.dart';
import 'package:re_mem_ui/features/cards/data/repositories/import_repository_impl.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/card_repository.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/import_repository.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/create_card.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/delete_card.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/get_cards.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/import_anki.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/import_tsv.dart';
import 'package:re_mem_ui/features/cards/domain/use_cases/submit_review.dart';

/// Provides the [CardRepository] implementation.
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(ref.watch(apiClientProvider));
});

/// Provides the [ImportRepository] implementation.
final importRepositoryProvider = Provider<ImportRepository>((ref) {
  return ImportRepositoryImpl(ref.watch(apiClientProvider));
});

/// Provides the [GetCardsUseCase].
final getCardsUseCaseProvider = Provider<GetCardsUseCase>((ref) {
  return GetCardsUseCase(ref.watch(cardRepositoryProvider));
});

/// Provides the [CreateCardUseCase].
final createCardUseCaseProvider = Provider<CreateCardUseCase>((ref) {
  return CreateCardUseCase(ref.watch(cardRepositoryProvider));
});

/// Provides the [SubmitReviewUseCase].
final submitReviewUseCaseProvider = Provider<SubmitReviewUseCase>((ref) {
  return SubmitReviewUseCase(ref.watch(cardRepositoryProvider));
});

/// Provides the [DeleteCard] use case.
final deleteCardUseCaseProvider = Provider<DeleteCard>((ref) {
  return DeleteCard(ref.watch(cardRepositoryProvider));
});

/// Provides the [ImportTsvUseCase].
final importTsvUseCaseProvider = Provider<ImportTsvUseCase>((ref) {
  return ImportTsvUseCase(ref.watch(importRepositoryProvider));
});

/// Provides the [ImportAnkiUseCase].
final importAnkiUseCaseProvider = Provider<ImportAnkiUseCase>((ref) {
  return ImportAnkiUseCase(ref.watch(importRepositoryProvider));
});
