/// Result returned by a successful import operation.
class ImportResult {
  const ImportResult({
    required this.cardsImported,
    required this.cardsSkipped,
  });

  final int cardsImported;
  final int cardsSkipped;

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(
        cardsImported: (json['cards_imported'] as num).toInt(),
        cardsSkipped: (json['cards_skipped'] as num).toInt(),
      );
}
