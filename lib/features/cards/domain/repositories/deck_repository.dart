import '../entities/deck.dart';

/// Abstract repository for deck operations
abstract class DeckRepository {
  /// Creates a new deck
  Future<Deck> createDeck({
    required String userId,
    required String name,
    String? description,
  });

  /// Gets all decks for a user
  Future<List<Deck>> getDecks(String userId);

  /// Gets a specific deck by ID
  Future<Deck> getDeckById(String deckId);

  /// Updates an existing deck
  Future<Deck> updateDeck({
    required String deckId,
    String? name,
    String? description,
  });

  /// Deletes a deck
  Future<void> deleteDeck(String deckId);
}
