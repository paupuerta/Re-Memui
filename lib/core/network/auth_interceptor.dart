import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:re_mem_ui/core/auth/auth_notifier.dart';
import 'package:re_mem_ui/core/auth/token_storage.dart';

/// Dio interceptor that:
/// 1. Injects `Authorization: Bearer <token>` on every request.
/// 2. On 401 response, forces logout and clears stored token.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _ref.read(tokenStorageProvider).readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _ref.read(authStateProvider.notifier).logout();
    }
    handler.next(err);
  }
}
