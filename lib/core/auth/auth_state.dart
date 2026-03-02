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
