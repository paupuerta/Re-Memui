# ReMem UI

Flutter frontend for the **ReMem** language-learning application.

## Overview

ReMem UI is the client-side application that interfaces with the [ReMem backend](../re-mem/) REST API. It provides a mobile and web experience for:

- Creating and managing flashcards
- Reviewing cards with FSRS-optimized scheduling
- AI-based answer checking feedback

## Tech Stack

- **Flutter** 3.x (web, Android, iOS)
- **Riverpod** — state management
- **Go Router** — navigation
- **Dio** — HTTP client
- **fpdart** — functional error handling
- **Freezed** — immutable models (code gen)

## Quick Start

```bash
# Prerequisites: Flutter SDK, ReMem backend running

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run tests
flutter test
```

## Documentation

- [AGENTS.md](AGENTS.md) — AI agent guidance
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — Architecture overview
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) — Development workflow
- [docs/PROJECT_CONTEXT.md](docs/PROJECT_CONTEXT.md) — Project context & scope

## Project Structure

```
lib/
├── main.dart              # Entry point
├── app.dart               # App configuration
├── core/                  # Shared infrastructure
│   ├── error/             # Failure types, Result
│   ├── network/           # API client
│   ├── router/            # Routes
│   └── theme/             # Theming
└── features/              # Feature modules
    ├── home/              # Home screen
    └── cards/             # Flashcard management
        ├── data/          # Repository implementations
        ├── domain/        # Entities, interfaces, use cases
        └── presentation/  # UI + state
```

## License

Private — not published to pub.dev.
