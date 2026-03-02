import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:re_mem_ui/core/network/network_providers.dart';
import 'package:re_mem_ui/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:re_mem_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:re_mem_ui/features/auth/domain/use_cases/login_user.dart';
import 'package:re_mem_ui/features/auth/domain/use_cases/register_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider));
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.watch(authRepositoryProvider));
});

final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});
