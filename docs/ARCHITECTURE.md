# ReMem UI — Architecture

## Overview

ReMem UI is a Flutter frontend that follows **Clean Architecture** with a feature-first folder structure. It communicates with the ReMem backend REST API.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                    │
│              (Flutter Widgets + Riverpod)                │
│  Screens  ←  Providers  ←  Use Cases                   │
└─────────────────┬───────────────────────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────────────────────┐
│                     DOMAIN LAYER                        │
│                   (Pure Dart only)                       │
│  Entities   Repository Interfaces   Use Cases           │
└─────────────────┬───────────────────────────────────────┘
                  │ implemented by
┌─────────────────▼───────────────────────────────────────┐
│                      DATA LAYER                         │
│              (Dio HTTP + JSON parsing)                  │
│  Repository Implementations   Data Sources              │
└─────────────────────────────────────────────────────────┘
                  │
                  ▼
        ┌─────────────────┐
        │  ReMem Backend   │
        │  REST API (Rust) │
        └─────────────────┘
```

## Folder Structure

```
lib/
├── main.dart                  # Bootstrap & ProviderScope
├── app.dart                   # MaterialApp.router
├── core/                      # Shared, cross-feature code
│   ├── error/                 # Failure types, Result alias
│   ├── network/               # Dio client, ApiClient wrapper
│   ├── router/                # GoRouter config
│   └── theme/                 # Material 3 theme
└── features/                  # Feature modules (vertical slices)
    └── <feature>/
        ├── data/              # Implementations (infra-aware)
        │   └── repositories/
        ├── domain/            # Pure business logic
        │   ├── entities/
        │   ├── repositories/  # Abstract interfaces
        │   └── use_cases/
        └── presentation/      # UI layer
            ├── providers/     # Riverpod state
            └── widgets/       # Reusable feature widgets
```

## State Management

**Riverpod** is used throughout:
- `Provider` for singletons (ApiClient, repositories, use cases)
- `StateNotifierProvider` / `AsyncNotifierProvider` for mutable state
- Providers are scoped per feature in `presentation/providers/`

## Routing

**GoRouter** with declarative routes defined in `core/router/app_router.dart`.

## Error Handling

Functional error handling via `fpdart`:
- `Result<T>` = `Either<Failure, T>`
- Sealed `Failure` class hierarchy
- No exceptions cross layer boundaries

## Testing Strategy

| Layer | What to test | How |
|-------|-------------|-----|
| Domain (entities) | Value equality, creation | Plain unit tests |
| Domain (use cases) | Delegates to repository | Mock repository with Mocktail |
| Data (repositories) | Maps API responses, handles errors | Mock ApiClient |
| Presentation (providers) | State transitions | ProviderContainer + mocked use cases |
| Presentation (widgets) | Renders correctly | Widget tests |

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| Clean Architecture | Same pattern as the backend (hexagonal) — team consistency |
| Riverpod over Bloc | Less boilerplate for MVP, compile-safe providers |
| fpdart Either | Explicit error handling, no uncaught exceptions |
| Feature-first structure | Scales with new features without cross-contamination |
| GoRouter | Declarative, deep-linking ready, official recommendation |
| Dio | Interceptors, cancellation, consistent with OpenAPI clients |
