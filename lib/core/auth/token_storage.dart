import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tokenKey = 'auth_token';
const _userIdKey = 'auth_user_id';

class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  Future<void> saveUserId(String userId) => _storage.write(key: _userIdKey, value: userId);
  Future<String?> readUserId() => _storage.read(key: _userIdKey);
  Future<void> deleteUserId() => _storage.delete(key: _userIdKey);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage(FlutterSecureStorage());
});
