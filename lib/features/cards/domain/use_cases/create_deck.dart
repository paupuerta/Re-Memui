import 'package:fpdart/fpdart.dart';
import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

/// Use case for creating a new deck
class CreateDeck {
  final DeckRepository repository;

  const CreateDeck(this.repository);

  Future<Either<String, Deck>> call({
    required String userId,
    required String name,
    String? description,
  }) async {
    try {
      final deck = await repository.createDeck(
        userId: userId,
        name: name,
        description: description,
      );
      return Right(deck);
    } catch (e) {
      return Left('Failed to create deck: ${e.toString()}');
    }
  }
}
