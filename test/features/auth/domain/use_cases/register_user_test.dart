import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:re_mem_ui/core/error/failure.dart';
import 'package:re_mem_ui/features/auth/domain/entities/auth_response.dart';
import 'package:re_mem_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:re_mem_ui/features/auth/domain/use_cases/register_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUser(mockRepository);
  });

  const tAuthResponse = AuthResponse(
    token: 'test_token',
    userId: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
  );

  group('RegisterUser', () {
    test('should return AuthResponse on success', () async {
      when(() => mockRepository.register(
            email: 'test@example.com',
            name: 'Test User',
            password: 'password123',
          )).thenAnswer((_) async => const Right(tAuthResponse));

      final result = await useCase(
        email: 'test@example.com',
        name: 'Test User',
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

    test('should return ValidationFailure when email already taken (409)', () async {
      when(() => mockRepository.register(
            email: any(named: 'email'),
            name: any(named: 'name'),
            password: any(named: 'password'),
          )).thenAnswer((_) async =>
              const Left(ValidationFailure('An account with this email already exists')));

      final result = await useCase(
        email: 'taken@example.com',
        name: 'User',
        password: 'password123',
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('should return ServerFailure on server error', () async {
      when(() => mockRepository.register(
            email: any(named: 'email'),
            name: any(named: 'name'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(ServerFailure()));

      final result = await useCase(
        email: 'test@example.com',
        name: 'User',
        password: 'password123',
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
