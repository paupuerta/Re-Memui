import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_storage.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.token});
  final String token;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final token = await ref.read(tokenStorageProvider).readToken();
    return token != null ? AuthAuthenticated(token: token) : const AuthUnauthenticated();
  }

  Future<void> login(String token) async {
    await ref.read(tokenStorageProvider).saveToken(token);
    state = AsyncData(AuthAuthenticated(token: token));
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).deleteToken();
    state = const AsyncData(AuthUnauthenticated());
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
