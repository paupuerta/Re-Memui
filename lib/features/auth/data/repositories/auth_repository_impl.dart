import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/core/network/api_client.dart';
import 'package:re_mem_ui/features/auth/domain/entities/auth_response.dart';
import 'package:re_mem_ui/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  AsyncResult<AuthResponse> register({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/register',
        data: {'email': email, 'name': name, 'password': password},
      );
      return Right(AuthResponse.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  AsyncResult<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      return Right(AuthResponse.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(_mapError(e));
    }
  }

  Failure _mapError(DioException e) {
    return switch (e.response?.statusCode) {
      409 => const ValidationFailure('An account with this email already exists'),
      401 => const ValidationFailure('Invalid email or password'),
      400 => const ValidationFailure('Invalid input'),
      _ => e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout
          ? const NetworkFailure()
          : const ServerFailure(),
    };
  }
}
