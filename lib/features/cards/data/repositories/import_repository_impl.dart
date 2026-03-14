import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/core/network/api_client.dart';
import 'package:re_mem_ui/features/cards/domain/entities/anki_import_result.dart';
import 'package:re_mem_ui/features/cards/domain/entities/import_result.dart';
import 'package:re_mem_ui/features/cards/domain/repositories/import_repository.dart';

/// Remote implementation of [ImportRepository].
class ImportRepositoryImpl implements ImportRepository {
  const ImportRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  AsyncResult<ImportResult> importTsv({
    required String deckId,
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  }) async {
    try {
      final response = await _apiClient.postMultipart(
        '/api/v1/decks/$deckId/import/tsv',
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      final json = response.data as Map<String, dynamic>;
      return Right(ImportResult.fromJson(json));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  @override
  AsyncResult<AnkiImportResult> importAnki({
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  }) async {
    try {
      final response = await _apiClient.postMultipart(
        '/api/v1/decks/import/anki',
        filePath: filePath,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      final json = response.data as Map<String, dynamic>;
      return Right(AnkiImportResult.fromJson(json));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    }
  }

  Failure _mapDioError(DioException e) {
    return switch (e.response?.statusCode) {
      404 => const NotFoundFailure(),
      400 => const ValidationFailure(),
      _ => e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout
          ? const NetworkFailure()
          : const ServerFailure(),
    };
  }
}
