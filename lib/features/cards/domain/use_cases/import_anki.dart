import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/features/cards/domain/entities/anki_import_result.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/import_repository.dart';

/// Use case: Import cards from an Anki .apkg archive (creates a new deck).
class ImportAnkiUseCase {
  const ImportAnkiUseCase(this._repository);

  final ImportRepository _repository;

  AsyncResult<AnkiImportResult> call({
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  }) =>
      _repository.importAnki(
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
}
