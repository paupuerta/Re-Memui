import 'package:flutter_test/flutter_test.dart';
import 'package:re_mem_ui/core/error/failure.dart';

void main() {
  group('Failure', () {
    test('ServerFailure has default message', () {
      const failure = ServerFailure();
      expect(failure.message, 'Server error occurred');
    });

    test('NetworkFailure has default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'Network connection failed');
    });

    test('NotFoundFailure has default message', () {
      const failure = NotFoundFailure();
      expect(failure.message, 'Resource not found');
    });

    test('ValidationFailure has default message', () {
      const failure = ValidationFailure();
      expect(failure.message, 'Validation error');
    });

    test('Failure toString returns message', () {
      const failure = ServerFailure('Custom error');
      expect(failure.toString(), 'Custom error');
    });

    test('Failure subtypes are exhaustive via sealed class', () {
      const Failure failure = ServerFailure();
      final result = switch (failure) {
        ServerFailure() => 'server',
        NetworkFailure() => 'network',
        NotFoundFailure() => 'notFound',
        ValidationFailure() => 'validation',
      };
      expect(result, 'server');
    });
  });
}
