class AuthResponse {
  const AuthResponse({required this.token, required this.userId, required this.email, required this.name});

  final String token;
  final String userId;
  final String email;
  final String name;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthResponse(
      token: json['token'] as String,
      userId: user['id'] as String,
      email: user['email'] as String,
      name: user['name'] as String,
    );
  }
}
