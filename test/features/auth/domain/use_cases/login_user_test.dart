import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/features/auth/domain/entities/auth_response.dart';
import 'package:re_mem_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:re_mem_ui/features/auth/domain/use_cases/login_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUser(mockRepository);
  });

  const tAuthResponse = AuthResponse(
    token: 'test_token',
    userId: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
  );

  group('LoginUser', () {
    test('should return AuthResponse on valid credentials', () async {
      when(() => mockRepository.login(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => const Right(tAuthResponse));

      final result = await useCase(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isRight(), true);
      result.fold(
        (f) => fail('Expected Right'),
        (auth) {
          expect(auth.token, 'test_token');
          expect(auth.userId, 'user-123');
        },
      );
    });

    test('should return ValidationFailure on wrong credentials (401)', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async =>
              const Left(ValidationFailure('Invalid email or password')));

      final result = await useCase(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<ValidationFailure>());
          expect(f.message, 'Invalid email or password');
        },
        (_) => fail('Expected Left'),
      );
    });

    test('should return NetworkFailure on connection error', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
