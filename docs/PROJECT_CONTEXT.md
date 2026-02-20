# ReMem UI — Project Context

## What is ReMem?

ReMem is an MVP language-learning application that combines:

1. **FSRS (Free Spaced Repetition Scheduler)** — An evidence-based algorithm (implemented via `fsrs-rs` in the Rust backend) that optimally schedules flashcard reviews based on memory strength and forgetting curves.

2. **AI-based Answer Checking** — Intelligent assessment of user answers that goes beyond exact string matching, understanding synonyms, partial correctness, and language nuances.

## System Components

```
┌──────────────┐       REST API       ┌──────────────────┐
│  re-mem-ui   │  ◄──────────────►    │    re-mem        │
│  (Flutter)   │    OpenAPI 3.0       │    (Rust/Axum)   │
│  Frontend    │                      │    Backend       │
└──────────────┘                      └────────┬─────────┘
                                               │
                                      ┌────────▼─────────┐
                                      │   PostgreSQL     │
                                      │   Database       │
                                      └──────────────────┘
```

### re-mem (Backend)
- **Language**: Rust
- **Framework**: Axum
- **Architecture**: Hexagonal (Ports & Adapters)
- **Database**: PostgreSQL
- **Key crate**: `fsrs-rs` for spaced repetition scheduling
- **API**: REST with OpenAPI/Swagger documentation

### re-mem-ui (Frontend) — This project
- **Framework**: Flutter/Dart
- **Architecture**: Clean Architecture (feature-first)
- **State Management**: Riverpod
- **HTTP Client**: Dio

## MVP Scope

The MVP focuses on the core learning loop:

1. **User creates flashcards** (question + answer pairs)
2. **System schedules reviews** using FSRS algorithm
3. **User reviews cards** and provides answer
4. **AI checks the answer** and assigns quality grade
5. **FSRS updates scheduling** based on the grade
6. **Repeat** — cards appear at optimal intervals for retention

### MVP Features (Frontend)
- User registration/identification
- Create and manage flashcards
- Review session (card presentation + answer input)
- Display next review schedule
- Basic progress overview

### Out of Scope (Phase 2+)
- Authentication (JWT/OAuth)
- Multi-language support
- Card import/export
- Social features
- Offline mode
- Push notifications

## FSRS Grade Scale

When reviewing a card, the user's response quality is graded:

| Grade | Label | Meaning |
|-------|-------|---------|
| 0 | Again | Completely forgot |
| 1 | Hard | Remembered with significant difficulty |
| 2 | Good | Remembered with some effort |
| 3 | Easy | Remembered easily |
| 4 | Very Easy | Instant recall |
| 5 | Perfect | Perfect, effortless recall |

The backend uses this grade to calculate the next optimal review date using the FSRS algorithm.

## API Contract

The frontend communicates with the backend via REST API following OpenAPI 3.0 spec. See `re-mem/docs/API.md` for full endpoint documentation.

Key entities:
- **User** — `{ id, email, name }`
- **Card** — `{ id, user_id, question, answer }`
- **Review** — `{ id, card_id, grade }`
