import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/core/auth/auth_state.dart';
import 'package:re_mem_ui/core/auth/token_storage.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockTokenStorage mockStorage;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  }

  setUp(() {
    mockStorage = MockTokenStorage();
  });

  group('AuthNotifier', () {
    test('initial state is AuthUnauthenticated when no token stored', () async {
      when(() => mockStorage.readToken()).thenAnswer((_) async => null);
      when(() => mockStorage.readUserId()).thenAnswer((_) async => null);

      final container = makeContainer();
      addTearDown(container.dispose);

      final state = await container.read(authStateProvider.future);
      expect(state, isA<AuthUnauthenticated>());
    });

    test('initial state is AuthAuthenticated when token and userId stored', () async {
      when(() => mockStorage.readToken()).thenAnswer((_) async => 'stored_token');
      when(() => mockStorage.readUserId()).thenAnswer((_) async => 'stored_user_id');

      final container = makeContainer();
      addTearDown(container.dispose);

      final state = await container.read(authStateProvider.future);
      expect(state, isA<AuthAuthenticated>());
      final auth = state as AuthAuthenticated;
      expect(auth.token, 'stored_token');
      expect(auth.userId, 'stored_user_id');
    });

    test('login persists token and userId and updates state', () async {
      when(() => mockStorage.readToken()).thenAnswer((_) async => null);
      when(() => mockStorage.readUserId()).thenAnswer((_) async => null);
      when(() => mockStorage.saveToken('new_token')).thenAnswer((_) async {});
      when(() => mockStorage.saveUserId('new_user_id')).thenAnswer((_) async {});

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);
      await container.read(authStateProvider.notifier).login('new_token', 'new_user_id');

      final state = container.read(authStateProvider).asData?.value;
      expect(state, isA<AuthAuthenticated>());
      final auth = state as AuthAuthenticated;
      expect(auth.token, 'new_token');
      expect(auth.userId, 'new_user_id');

      verify(() => mockStorage.saveToken('new_token')).called(1);
      verify(() => mockStorage.saveUserId('new_user_id')).called(1);
    });

    test('logout clears storage and sets AuthUnauthenticated', () async {
      when(() => mockStorage.readToken()).thenAnswer((_) async => 'stored_token');
      when(() => mockStorage.readUserId()).thenAnswer((_) async => 'stored_user_id');
      when(() => mockStorage.deleteToken()).thenAnswer((_) async {});
      when(() => mockStorage.deleteUserId()).thenAnswer((_) async {});

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);
      await container.read(authStateProvider.notifier).logout();

      final state = container.read(authStateProvider).asData?.value;
      expect(state, isA<AuthUnauthenticated>());

      verify(() => mockStorage.deleteToken()).called(1);
      verify(() => mockStorage.deleteUserId()).called(1);
    });
  });
}
