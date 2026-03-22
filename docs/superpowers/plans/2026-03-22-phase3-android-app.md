# Phase 3: Android App (Kotlin/Jetpack Compose)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the native Android app — the second client for interactions.work. Implements the same protocol spec as iOS: auth, team management, interactions (kudos/feedback), OKRs, and E2E encrypted relay sync.

**Architecture:** Jetpack Compose app with MVVM pattern. Local SQLite via Room. Tink for E2E encryption (X25519 + AES-256-GCM). Ktor or OkHttp for REST API, OkHttp WebSocket for relay sync.

**Tech Stack:** Kotlin, Jetpack Compose, Room, Tink, OkHttp/Ktor, Hilt (DI)

**Prerequisites:**
- Android Studio
- Android SDK (API 28+)
- Relay server running locally

**Spec:** `docs/superpowers/specs/2026-03-22-interactions-work-v1-design.md`

---

## Overview

Mirror of the iOS app, implementing the same protocol spec independently. Same features, same sync protocol, idiomatic Kotlin/Compose patterns.

## File Structure

```
android/app/src/main/java/work/interactions/app/
├── InteractionsApp.kt
├── data/
│   ├── db/
│   │   ├── AppDatabase.kt
│   │   ├── dao/
│   │   └── entities/
│   ├── api/
│   │   └── ApiClient.kt
│   ├── sync/
│   │   ├── SyncService.kt
│   │   └── EnvelopeHandler.kt
│   └── crypto/
│       └── CryptoService.kt
├── domain/
│   ├── models/
│   │   ├── Team.kt
│   │   ├── ManifestoValue.kt
│   │   ├── Member.kt
│   │   ├── Interaction.kt
│   │   ├── TeamObjective.kt
│   │   └── PersonalObjective.kt
│   └── repositories/
├── ui/
│   ├── theme/
│   ├── onboarding/
│   ├── home/
│   ├── interact/
│   ├── goals/
│   ├── profile/
│   └── team/
└── di/
    └── AppModule.kt
```

## Task Sequence

### Task 1: Create Android Studio Project
- [ ] New Project → Empty Compose Activity
- [ ] Package: work.interactions.app
- [ ] Min SDK: API 28 (Android 9)
- [ ] Add dependencies: Room, Tink, OkHttp, Hilt, Navigation Compose

### Task 2: Define Room Entities and DAOs
- [ ] Mirror all SwiftData models from iOS
- [ ] Same fields, same types, same relationships

### Task 3: API Client
- [ ] OkHttp-based REST client for all endpoints
- [ ] JWT storage in EncryptedSharedPreferences

### Task 4: Crypto Service
- [ ] Tink for X25519 key exchange
- [ ] AES-256-GCM encryption/decryption
- [ ] Key storage in Android Keystore

### Task 5: Sync Service
- [ ] OkHttp WebSocket to /sync
- [ ] Envelope handling, offline queue in Room

### Tasks 6-10: UI Implementation
- [ ] Same screen structure as iOS, idiomatic Compose
- [ ] Material 3 design language
- [ ] Same features, same user flows

---

**Note:** Same higher-level structure as the iOS plan. Each task is a focused session. The protocol spec ensures both apps behave identically.
