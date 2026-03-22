# Phase 2: iOS App (Swift/SwiftUI)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the native iOS app — the primary client for interactions.work. Implements the full protocol spec: auth, team management, interactions (kudos/feedback), OKRs, and E2E encrypted relay sync.

**Architecture:** SwiftUI app with MVVM pattern. Local SQLite via SwiftData. CryptoKit for E2E encryption (X25519 + AES-256-GCM). URLSession for REST API, URLSessionWebSocketTask for relay sync.

**Tech Stack:** Swift 5.9+, SwiftUI, SwiftData, CryptoKit, URLSession

**Prerequisites:**
- Xcode 15+ on macOS
- Apple Developer account
- Relay server running locally (`cd server && cargo run`) with PostgreSQL via `docker-compose up -d`

**Spec:** `docs/superpowers/specs/2026-03-22-interactions-work-v1-design.md`

---

## Overview

This plan creates the iOS app from scratch. It follows the protocol spec and produces an app that can:
1. Authenticate via 6-digit email code
2. Create and join teams with manifesto values
3. Send kudos and feedback to team members
4. Set personal and team OKRs
5. Sync with other devices via the E2E encrypted relay

The app is organized into these layers:
- **Models** — SwiftData entities matching the protocol spec
- **Services** — API client, WebSocket sync, encryption
- **ViewModels** — business logic per screen
- **Views** — SwiftUI screens and components

## File Structure

```
ios/InteractionsWork/
├── InteractionsWorkApp.swift
├── Models/
│   ├── Team.swift
│   ├── ManifestoValue.swift
│   ├── Member.swift
│   ├── Interaction.swift
│   ├── TeamObjective.swift
│   ├── PersonalObjective.swift
│   └── Envelope.swift
├── Services/
│   ├── APIClient.swift
│   ├── SyncService.swift
│   ├── CryptoService.swift
│   └── KeychainService.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── HomeViewModel.swift
│   ├── InteractViewModel.swift
│   ├── GoalsViewModel.swift
│   └── ProfileViewModel.swift
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   ├── EmailView.swift
│   │   ├── VerifyCodeView.swift
│   │   ├── ProfileSetupView.swift
│   │   └── GetStartedView.swift
│   ├── Main/
│   │   ├── MainTabView.swift
│   │   ├── HomeView.swift
│   │   ├── InteractView.swift
│   │   ├── GoalsView.swift
│   │   └── ProfileView.swift
│   ├── Team/
│   │   ├── CreateTeamView.swift
│   │   ├── JoinTeamView.swift
│   │   ├── ManifestoEditorView.swift
│   │   └── MembersView.swift
│   ├── Interactions/
│   │   ├── SendKudosView.swift
│   │   ├── GiveFeedbackView.swift
│   │   └── InteractionDetailView.swift
│   └── Goals/
│       ├── TeamGoalsView.swift
│       ├── PersonalGoalsView.swift
│       ├── CreateObjectiveView.swift
│       └── KeyResultUpdateView.swift
└── Utilities/
    └── Extensions.swift
```

## Task Sequence

Execute on macOS with Xcode. Create the Xcode project first, then add files task by task.

### Task 1: Create Xcode Project
- [ ] Open Xcode → File → New → Project → iOS App
- [ ] Product Name: InteractionsWork
- [ ] Organization: interactions.work
- [ ] Interface: SwiftUI, Language: Swift, Storage: SwiftData
- [ ] Save to `ios/` directory in the repo
- [ ] Verify it builds and runs in simulator

### Task 2: Define SwiftData Models
- [ ] Create all model files matching the protocol spec data model
- [ ] Each entity maps 1:1 to the spec
- [ ] Use UUIDs for all IDs, Date for timestamps
- [ ] Build and verify no compiler errors

### Task 3: API Client
- [ ] Create APIClient.swift with all REST endpoints
- [ ] Handle JWT storage in Keychain
- [ ] Test against local relay server

### Task 4: Crypto Service
- [ ] Implement X25519 key generation with CryptoKit
- [ ] AES-256-GCM encryption/decryption
- [ ] Key storage in Keychain

### Task 5: Sync Service
- [ ] WebSocket connection to /sync endpoint
- [ ] Envelope send/receive
- [ ] Offline queue in SwiftData
- [ ] Conflict resolution per protocol spec

### Task 6: Onboarding Flow
- [ ] Welcome slides
- [ ] Email input + 6-digit code verification
- [ ] Profile setup (name, avatar)
- [ ] Create team or join via invite code

### Task 7: Home Tab
- [ ] Team feed with recent interactions
- [ ] Manifesto display
- [ ] Quick kudos action button

### Task 8: Interact Tab
- [ ] Send kudos flow (person → value → message)
- [ ] Give feedback flow
- [ ] Interaction history

### Task 9: Goals Tab
- [ ] Team objectives (Our Goals)
- [ ] Personal objectives (My Goals)
- [ ] Key result progress updates

### Task 10: Profile Tab + Team Management
- [ ] Profile editing
- [ ] Team switching
- [ ] Manifesto editor (leaders)
- [ ] Member management (leaders)
- [ ] Settings, notifications, data export

---

**Note:** This plan is intentionally at a higher level than Phase 1 because it requires Xcode on macOS. Each task should be executed as a focused session on the Mac Mini. The protocol spec provides all the data model details and sync behavior.
