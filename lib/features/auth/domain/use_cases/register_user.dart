import 'package:re_mem_ui/core/error/result.dart';
import 'package:re_mem_ui/features/auth/domain/entities/auth_response.dart';
import 'package:re_mem_ui/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResponse>> call({
    required String email,
    required String name,
    required String password,
  }) =>
      _repository.register(email: email, name: name, password: password);
}
