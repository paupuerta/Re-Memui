import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../repositories/deck_repository.dart';

/// Use case for deleting a deck
/// Note: Cards in the deck will have their deck_id set to NULL (ON DELETE SET NULL)
class DeleteDeck {
  const DeleteDeck(this._repository);

  final DeckRepository _repository;

  AsyncResult<void> call({
    required String userId,
    required String deckId,
  }) async {
    try {
      await _repository.deleteDeck(userId: userId, deckId: deckId);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
