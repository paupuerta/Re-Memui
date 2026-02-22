import 'package:dartz/dartz.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

/// Use case for getting all decks for a user
class GetDecks {
  final DeckRepository repository;

  const GetDecks(this.repository);

  Future<Either<String, List<Deck>>> call(String userId) async {
    try {
      final decks = await repository.getDecks(userId);
      return Right(decks);
    } catch (e) {
      return Left('Failed to get decks: ${e.toString()}');
    }
  }
}
