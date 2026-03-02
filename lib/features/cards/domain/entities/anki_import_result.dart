/// Result returned by an Anki import operation (includes new deck info).
class AnkiImportResult {
  const AnkiImportResult({
    required this.deckId,
    required this.deckName,
    required this.cardsImported,
    required this.cardsSkipped,
  });

  final String deckId;
  final String deckName;
  final int cardsImported;
  final int cardsSkipped;

  factory AnkiImportResult.fromJson(Map<String, dynamic> json) =>
      AnkiImportResult(
        deckId: json['deck_id'] as String,
        deckName: json['deck_name'] as String,
        cardsImported: (json['cards_imported'] as num).toInt(),
        cardsSkipped: (json['cards_skipped'] as num).toInt(),
      );
}
