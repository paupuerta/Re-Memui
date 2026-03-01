import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/features/cards/domain/entities/import_result.dart';

/// Repository contract for deck import operations.
abstract interface class ImportRepository {
  /// Import cards from a TSV file into [deckId].
  AsyncResult<ImportResult> importTsv({
    required String deckId,
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  });

  /// Import an Anki .apkg archive, creating a new deck automatically.
  AsyncResult<AnkiImportResult> importAnki({
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  });
}
