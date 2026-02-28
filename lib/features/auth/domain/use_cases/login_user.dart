import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/features/auth/domain/entities/auth_response.dart';
import 'package:re_mem_ui/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResponse>> call({
    required String email,
    required String password,
  }) =>
      _repository.login(email: email, password: password);
}
