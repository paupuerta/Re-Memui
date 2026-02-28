import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/features/cards/domain/entities/import_result.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/import_repository.dart';

/// Use case: Import cards from a TSV file into an existing deck.
class ImportTsvUseCase {
  const ImportTsvUseCase(this._repository);

  final ImportRepository _repository;

  AsyncResult<ImportResult> call({
    required String deckId,
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  }) =>
      _repository.importTsv(
        deckId: deckId,
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
}
