import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tokenKey = 'auth_token';

class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage(FlutterSecureStorage());
});
