import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_mem_ui/core/auth/auth_state.dart';
import 'package:re_mem_ui/core/auth/token_storage.dart';

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
