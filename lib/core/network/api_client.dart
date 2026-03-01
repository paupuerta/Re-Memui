import 'package:dio/dio.dart';

/// Constants for the API configuration.
abstract final class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
}

/// Thin wrapper around [Dio] for API calls.
/// Keeps HTTP details in one place (SRP).
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) =>
      _dio.post(path, data: data);

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) =>
      _dio.put(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete(path);

  /// Upload a file via multipart/form-data. The file is sent under the `file` field.
  Future<Response<T>> postMultipart<T>(
    String path, {
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  }) async {
    final multipartFile = fileBytes != null
        ? MultipartFile.fromBytes(fileBytes, filename: fileName)
        : filePath != null
            ? await MultipartFile.fromFile(filePath, filename: fileName)
            : throw ArgumentError(
                'Either filePath or fileBytes must be provided.',
              );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });
    return _dio.post(path, data: formData);
  }
}
