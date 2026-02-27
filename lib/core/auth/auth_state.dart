import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_storage.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.token, required this.userId});
  final String token;
  final String userId;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.readToken();
    final userId = await storage.readUserId();
    if (token != null && userId != null) {
      return AuthAuthenticated(token: token, userId: userId);
    }
    return const AuthUnauthenticated();
  }

  Future<void> login(String token, String userId) async {
    final storage = ref.read(tokenStorageProvider);
    await storage.saveToken(token);
    await storage.saveUserId(userId);
    state = AsyncData(AuthAuthenticated(token: token, userId: userId));
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    await storage.deleteToken();
    await storage.deleteUserId();
    state = const AsyncData(AuthUnauthenticated());
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
