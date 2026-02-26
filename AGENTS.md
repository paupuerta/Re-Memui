# ReMem UI — AGENTS.md

This document provides comprehensive guidance for AI agents working on the ReMem frontend project.

## Project Overview

ReMem UI is a Flutter/Dart frontend for the **ReMem** language-learning MVP. It consumes the ReMem REST API (OpenAPI 3.0) which provides FSRS-based spaced repetition and AI-based answer checking.

**Tech stack:**

- **Flutter** (multi-platform: web, Android, iOS)
- **Dart** (SDK ^3.11.0)
- **Riverpod** — state management
- **Go Router** — declarative routing
- **Dio** — HTTP client
- **fpdart** — functional error handling (`Either` / `Result`)
- **Freezed** — immutable data classes & unions (code generation)
- **Mocktail** — testing mocks

## Architecture

The project follows **Clean Architecture** with a feature-first folder structure:

```bash
lib/
├── main.dart                     # Entry point
├── app.dart                      # MaterialApp configuration
├── core/                         # Shared infrastructure
│   ├── error/                    # Failure types, Result typedef
│   ├── network/                  # Dio client, API constants
│   ├── router/                   # Go Router configuration
│   └── theme/                    # App-wide theming
└── features/                     # Feature modules
    ├── home/                     # Home / dashboard
    │   └── presentation/
    └── cards/                    # Flashcard feature
        ├── data/                 # Repository implementations
        │   └── repositories/
        ├── domain/               # Business logic (pure Dart)
        │   ├── entities/
        │   ├── repositories/     # Abstract interfaces
        │   └── use_cases/
        └── presentation/         # UI + providers
            └── providers/
```

### Layer Rules

| Layer | Depends on | Contains |
| --- | --- | --- |
| **Domain** | Nothing (pure Dart) | Entities, Repository interfaces, Use cases |
| **Data** | Domain, Core/network | Repository implementations, Data sources |
| **Presentation** | Domain, Core | Widgets, Riverpod providers, Screens |
| **Core** | Flutter SDK only | Network client, Error types, Router, Theme |

### Dependency Flow

```text
Presentation → Domain ← Data
                 ↑
               Core
```

The **Domain layer never imports Flutter, Dio, or any infrastructure package**.

## Key Principles

### SOLID

- **S** — Single Responsibility: One use case per class, one widget per concern.
- **O** — Open/Closed: Use abstract interfaces (e.g., `CardRepository`) for extension.
- **L** — Liskov Substitution: Implementations are swappable via Riverpod providers.
- **I** — Interface Segregation: Repository contracts expose only needed methods.
- **D** — Dependency Inversion: Domain defines interfaces; Data layer implements them.

### KISS

- Minimal layers — no abstraction without a reason.
- Prefer composition over inheritance.
- Flat widget trees when possible.

### YAGNI

- No feature scaffolding beyond what is in progress.
- No speculative code, no unused providers.

### TDD Workflow

1. Write a failing test.
2. Write the minimum code to pass.
3. Refactor.

Tests live in `test/` mirroring `lib/` structure.

## Backend API

The backend runs at `http://localhost:3000/api/v1` (configurable via `ApiConstants`).

### Key Endpoints

| Method | Path | Description |
| --- | --- | --- |
| POST | `/users` | Create user |
| GET | `/users/{user_id}` | Get user |
| POST | `/users/{user_id}/cards` | Create card |
| GET | `/users/{user_id}/cards` | List cards |
| POST | `/users/{user_id}/cards/{card_id}/reviews` | Submit review (FSRS grade 0-5) |
| GET | `/health` | Health check |

See the backend `re-mem/docs/API.md` for full documentation.

## Error Handling

Errors use `fpdart`'s `Either<Failure, T>` (aliased as `Result<T>`).

Failure hierarchy (sealed class):

- `ServerFailure` — 5xx or unknown server errors
- `NetworkFailure` — connection / timeout issues
- `NotFoundFailure` — 404
- `ValidationFailure` — 400

Repository implementations catch `DioException` and map to `Failure`.

## Common Tasks

### Adding a New Feature

1. Create `lib/features/<name>/domain/entities/` — domain models (plain Dart).
2. Create `lib/features/<name>/domain/repositories/` — abstract interface.
3. Create `lib/features/<name>/domain/use_cases/` — one class per use case.
4. Create `lib/features/<name>/data/repositories/` — implementation using `ApiClient`.
5. Create `lib/features/<name>/presentation/providers/` — Riverpod providers.
6. Create `lib/features/<name>/presentation/` — screens and widgets.
7. Add route in `lib/core/router/app_router.dart`.
8. Write tests for each layer in `test/features/<name>/`.

### Adding a New API Call

1. Add method to repository interface (domain layer).
2. Implement in repository impl (data layer) using `ApiClient`.
3. Create use case if needed.
4. Write unit test with `Mocktail` mock of repository.

### Running Tests

```bash
flutter test                    # All tests
flutter test test/features/     # Feature tests only
flutter test --coverage         # With coverage
```

### Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs  # Watch mode
```

## Conventions

- **File naming**: `snake_case.dart`
- **Class naming**: `PascalCase`
- **Private members**: prefix with `_`
- **Providers**: suffix with `Provider` (e.g., `cardRepositoryProvider`)
- **Use cases**: one public `call()` method (callable class pattern)
- **Imports**: prefer `package:re_mem_ui/...` absolute imports
- **Trailing commas**: always (enforced by linter)
- **Single quotes**: always (enforced by linter)
- **Const constructors**: always when possible (enforced by linter)

## Do NOT

- Import infrastructure packages in the domain layer.
- Add features or code that is not currently needed (YAGNI).
- Use `print()` for logging — use the `logging` package or Dio interceptors.
- Skip writing tests for new use cases or repository implementations.
- Modify generated files (`*.freezed.dart`, `*.g.dart`).
- Use the `http` package — this project uses **Dio** for all HTTP requests.

## Common Pitfalls & Solutions

### ❌ Problem: Using `http` package instead of `Dio`

**Error:**

```dart
Error: Not found: 'package:http/http.dart'
Error: Type 'http.Client' not found.
```

**Root Cause:**
This project uses `Dio` (defined in `pubspec.yaml`), not the `http` package.

**Solution:**
Always use the existing `dioProvider` from `core/network/network_providers.dart`:

```dart
// ❌ WRONG - Using http package
import 'package:http/http.dart' as http;

class MyRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  
  Future<Model> getData() async {
    final response = await client.get(Uri.parse('$baseUrl/path'));
    return Model.fromJson(jsonDecode(response.body));
  }
}

// ✅ CORRECT - Using Dio
import 'package:dio/dio.dart';

class MyRemoteDataSource {
  final Dio dio;
  
  Future<Model> getData() async {
    final response = await dio.get('/path');
    return Model.fromJson(response.data);
  }
}
```

**Provider Pattern:**

```dart
// ✅ CORRECT - Follow existing pattern
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_providers.dart';

final myRemoteDataSourceProvider = Provider<MyRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);  // ← Use existing dioProvider
  return MyRemoteDataSource(dio: dio);
});
```

### ❌ Problem: Wrong API constants import

**Error:**

```dart
Error: Couldn't resolve the package 'ApiConfig'
```

**Solution:**
Use `ApiConstants` from `core/network/api_client.dart`:

```dart
// ❌ WRONG
import '../../../cards/data/data_sources/api_config.dart';
baseUrl: ApiConfig.baseUrl;

// ✅ CORRECT
import '../../../../core/network/api_client.dart';
baseUrl: ApiConstants.baseUrl;
```

### ❌ Problem: Outdated `const` syntax in Flutter widgets

**Error:**

```dart
Syntax error: children: const [...]
```

**Solution:**
Move `const` to the widget constructor:

```dart
// ❌ WRONG - Deprecated syntax
Row(
  children: const [
    Icon(Icons.check),
    Text('Hello'),
  ],
)

// ✅ CORRECT - Modern Flutter syntax
const Row(
  children: [
    Icon(Icons.check),
    Text('Hello'),
  ],
)
```

### ✅ Standard Architecture Pattern for New Features

When adding a new feature (e.g., `statistics`), follow this exact structure:

**1. Data Source (uses Dio):**

```dart
class StatisticsRemoteDataSource {
  final Dio dio;
  
  StatisticsRemoteDataSource({required this.dio});
  
  Future<UserStatsModel> getUserStats(String userId) async {
    final response = await dio.get('/api/v1/users/$userId/stats');
    return UserStatsModel.fromJson(response.data);
  }
}
```

**2. Repository Implementation:**

```dart
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;
  
  StatisticsRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<UserStats> getUserStats(String userId) async {
    final model = await remoteDataSource.getUserStats(userId);
    return model.toEntity();
  }
}
```

**3. Providers (chain dependencies):**

```dart
// Use existing dioProvider from core
final statsRemoteDataSourceProvider = Provider<StatsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return StatsRemoteDataSource(dio: dio);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final remoteDataSource = ref.watch(statsRemoteDataSourceProvider);
  return StatsRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getUserStatsUseCaseProvider = Provider<GetUserStats>((ref) {
  final repository = ref.watch(statsRepositoryProvider);
  return GetUserStats(repository);
});
```

This follows the **exact same pattern** used in:

- `lib/features/cards/presentation/providers/card_providers.dart`
- `lib/features/cards/presentation/providers/deck_providers.dart`

### Dependency Chain Diagram

```text
core/network/network_providers.dart
        ↓
    dioProvider (configured Dio instance)
        ↓
feature/data/data_sources/*_remote_data_source.dart
        ↓
feature/data/repositories/*_repository_impl.dart
        ↓
feature/domain/use_cases/*.dart
        ↓
feature/presentation/screens/*.dart
```

**Key Rule:** Always check existing features first before creating new infrastructure. Reuse `dioProvider`, `ApiConstants`, and follow established patterns.
