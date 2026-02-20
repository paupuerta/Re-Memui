# ReMem UI — Development Guide

## Prerequisites

- Flutter SDK ^3.11.0
- Dart SDK ^3.11.0
- ReMem backend running at `http://localhost:3000` (see `re-mem/` project)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Run the app (Chrome)
flutter run -d chrome

# Run the app (connected device/emulator)
flutter run
```

## Development Workflow

### TDD Cycle

1. **Red** — Write a failing test in `test/`.
2. **Green** — Write the minimum code in `lib/` to make it pass.
3. **Refactor** — Clean up while keeping tests green.

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/features/cards/domain/use_cases/get_cards_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Code Generation

Freezed and json_serializable require a build step:

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (recommended during development)
dart run build_runner watch --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
dart fix --apply  # Auto-fix lint issues
```

## Project Structure Convention

When adding a new feature, follow the vertical-slice pattern:

```
lib/features/<feature_name>/
├── data/
│   └── repositories/          # API integration
├── domain/
│   ├── entities/              # Business objects
│   ├── repositories/          # Contracts (abstract)
│   └── use_cases/             # Business operations
└── presentation/
    ├── providers/             # Riverpod state management
    ├── screens/               # Full-screen widgets
    └── widgets/               # Reusable components
```

## Environment Configuration

API base URL is configured in `lib/core/network/api_client.dart`:

```dart
abstract final class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api/v1';
}
```

For different environments, this can be overridden via Riverpod provider overrides in `main.dart`.

## Useful Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter test` | Run all tests |
| `flutter analyze` | Lint check |
| `flutter run -d chrome` | Run on Chrome |
| `flutter build web` | Build for web deployment |
| `dart run build_runner build` | Generate freezed/json code |
