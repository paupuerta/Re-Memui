import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/features/auth/domain/entities/auth_response.dart';

abstract interface class AuthRepository {
  Future<Result<AuthResponse>> register({
    required String email,
    required String name,
    required String password,
  });

  Future<Result<AuthResponse>> login({
    required String email,
    required String password,
  });
}
