# CLAUDE.md - AI Assistant Guidelines

This document provides guidance for AI assistants working with the interactions.work codebase.

## Project Overview

**interactions.work** is a mobile app for any group of humans to strengthen how they work together through shared values, appreciation, feedback, and goals. It serves professional teams, sports teams, volunteer groups, open source projects, and cross-organization collaborations equally.

The app is device-first: data lives on the user's phone, synced between team members via end-to-end encrypted relay. The server never sees interaction content.

### Core Philosophy

- Focus on the positive: kudos, appreciation, recognition
- Don't hide from the hard parts: feedback, apologies, difficult conversations
- Soft skills over hard metrics
- Private by default, intentional sharing
- The interactions are the product, not the team type

### Key Documents

- **Intent:** `docs/intent/main.md` — why the app exists, core beliefs, market positioning
- **Design Spec:** `docs/superpowers/specs/2026-03-22-interactions-work-v1-design.md` — full v1 specification
- **Read intent before making architectural decisions.** When intent and implementation conflict, intent wins.

## Technology Stack

| Component | Technology | Notes |
|-----------|------------|-------|
| iOS App | Swift / SwiftUI | Native, minimum iOS 17 |
| Android App | Kotlin / Jetpack Compose | Native, minimum API 28 (Android 9) |
| Relay Server | Rust (Axum) | Hetzner VPS, EU |
| Database | PostgreSQL | Team registry, envelope queue |
| Email | Resend | Transactional 6-digit verification codes |
| Push | APNs (iOS) + FCM (Android) | Content-free notifications |
| Marketing Website | Astro (static) | Cloudflare Pages |

## Architecture: Protocol-Driven, Device-First

### Design Principle

**Both native apps implement the same protocol specification independently.** There is no shared library or cross-platform framework. The design spec is the contract. Interoperability tests verify both implementations speak the same language.

```
┌─────────────────────────────────────────────────────────────┐
│                      Native Apps                            │
├─────────────────────────────┬───────────────────────────────┤
│    iOS (Swift/SwiftUI)      │   Android (Kotlin/Compose)    │
│    - Local SQLite           │   - Local Room (SQLite)       │
│    - CryptoKit (E2E)        │   - Tink/libsodium (E2E)     │
│    - Sync protocol client   │   - Sync protocol client     │
├─────────────────────────────┴───────────────────────────────┤
│              WebSocket (E2E encrypted envelopes)            │
├─────────────────────────────────────────────────────────────┤
│              Relay Server (Rust/Axum, Hetzner EU)           │
│    - Team registry (create/join/invite)                     │
│    - E2E encrypted message relay (zero knowledge)           │
│    - Auth (email + 6-digit code → JWT)                      │
└─────────────────────────────────────────────────────────────┘
```

### What Goes Where

| Layer | Responsibility | Examples |
|-------|----------------|----------|
| **ios/** | iOS UI + platform integrations | SwiftUI views, CryptoKit encryption, APNs |
| **android/** | Android UI + platform integrations | Compose UI, Tink encryption, FCM |
| **server/** | Team registry, relay, auth | Axum routes, PostgreSQL, WebSocket relay |
| **website/** | Marketing + invite handler | Astro pages, Cloudflare Worker for invites |
| **docs/protocol/** | Wire format, sync spec | Envelope format, conflict resolution rules |
| **tests/interop/** | Cross-platform verification | Encrypt/decrypt test vectors, sync scenarios |

### Protocol-Driven Development

Both apps implement against the same spec. When adding a feature:

1. **Update the protocol spec** if it affects wire format or sync behavior
2. **Implement in both apps independently** — same behavior, idiomatic code per platform
3. **Run interop tests** to verify both implementations are compatible
4. **Server changes are minimal** — the server is a relay, not a logic layer

## Data Model

| Entity | Key Fields | Sync Rule |
|--------|------------|-----------|
| **Team** | id, name, vision, invite_code | Always syncs to all members |
| **ManifestoValue** | id, team_id, title, emoji | Always syncs (leaders write) |
| **Member** | id, team_id, email, display_name, role | Always syncs (self writes) |
| **Interaction** | id, kind (kudos/feedback), from, to[], message, value_id, visibility | Team → all; Private → recipient only |
| **TeamObjective** | id, team_id, title, value_id, quarter, key_results[] | Always syncs (leaders create) |
| **PersonalObjective** | id, owner, team_id, title, value_id, visibility, key_results[] | Shared → all; Private → never |

Full model details in the design spec.

## Repository Structure

```
interactions.work/
├── CLAUDE.md
├── README.md
├── docs/
│   ├── intent/                # Business intent and core beliefs
│   ├── protocol/              # Wire format, sync protocol spec
│   ├── superpowers/specs/     # Design specifications
│   └── legal/                 # Privacy policy, terms, GDPR docs
├── ios/                       # Swift/SwiftUI app
│   ├── InteractionsWork/
│   └── InteractionsWork.xcodeproj
├── android/                   # Kotlin/Compose app
│   ├── app/
│   └── build.gradle.kts
├── server/                    # Rust relay server
│   ├── src/
│   └── Cargo.toml
├── website/                   # Astro marketing site
│   ├── src/
│   └── astro.config.mjs
└── tests/
    └── interop/               # Cross-platform interoperability tests
```

## Pricing

| Tier | Price | Notes |
|------|-------|-------|
| **Free** | €0 forever | All core features, unlimited members, P2P encrypted sync |
| **Pro** | €10/month flat per team | Cloud sync & backup (rolling out post-launch) |
| **Community** | €0 (Pro features) | Volunteer groups and community organizations |

## Privacy & Encryption

The server is deliberately dumb — zero knowledge of content:

| What the server stores | Purpose |
|------------------------|---------|
| Email addresses | Auth + team membership |
| Team ID + name | Registry + invite resolution |
| Encrypted envelopes | Offline delivery (30-day TTL) |
| Push tokens | Notification delivery |

**The server NEVER sees:** interaction content, manifesto text, OKR details, who sent kudos to whom.

- E2E encryption: X25519 key exchange + AES-256-GCM
- Team-visible content encrypted with shared team key
- Private content encrypted with recipient's individual public key (N separate envelopes for N recipients)
- All infrastructure EU-hosted (Hetzner, Germany) — GDPR compliant

## Development Guidelines

### Branching Strategy

- `main` - Stable releases
- `feature/*` - New features
- `fix/*` - Bug fixes
- `chore/*` - Maintenance tasks

### Code Style

**Rust (server):**
- Follow Rust 2021 edition idioms
- Use `cargo fmt` before committing
- Use `cargo clippy` for linting
- Aim for zero warnings

**Swift (iOS):**
- Follow Swift API Design Guidelines
- Use SwiftLint if configured
- SwiftUI views should be small and composable

**Kotlin (Android):**
- Follow Kotlin coding conventions
- Use ktlint or detekt if configured
- Compose functions should be small and focused

**Website (Astro):**
- Follow Astro conventions
- Minimal JavaScript — static by default

### Testing

- Unit tests for business logic in each app
- Integration tests for server API and WebSocket
- Interoperability tests for cross-platform sync verification
- Encryption tests with shared test vectors

### Commit Messages

Follow Conventional Commits:

```
feat(ios): add kudos sending flow
feat(android): add team manifesto editor
feat(server): add member removal endpoint
fix(server): handle expired JWT on WebSocket reconnect
docs: update protocol spec for private envelope format
```

Prefix with component when the change is platform-specific.

## AI Assistant Guidelines

### When Making Changes

1. **Read the intent document first** — understand why before changing what
2. **Read the design spec** — the protocol is the contract between platforms
3. **Respect the domain** — this is about human interactions, not task management
4. **Privacy first** — never weaken encryption or expose private data
5. **Keep it simple** — soft skills don't need complex code
6. **Test encryption thoroughly** — private means private

### Implementing New Features

1. **Check if it affects the protocol** — if it changes wire format or sync, update `docs/protocol/` first
2. **Implement in the target platform** — iOS or Android, using idiomatic patterns
3. **Mirror in the other platform** — same behavior, different code
4. **Update server if needed** — relay changes are rare; most features are client-side
5. **Add interop test vectors** — verify both platforms handle the same data identically

### Key Principles

- The manifesto is sacred — it defines team culture
- Interactions are append-only — once sent, they cannot be modified
- Encryption must be correct — private means private
- The server is a relay, not a brain — keep it dumb
- Both apps must speak the same protocol — interop tests prove it

### Things to Avoid

- Don't weaken E2E encryption for convenience
- Don't store content on the server — it's a relay
- Don't add hard metric tracking — this is about soft skills
- Don't over-engineer — keep the focus on human connection
- Don't break protocol compatibility between platforms
- Don't add features without checking the design spec scope (v1 vs deferred)

## Quick Reference

| Task | Command |
|------|---------|
| **Server tests** | `cd server && cargo test` |
| **Server check** | `cd server && cargo clippy` |
| **Server format** | `cd server && cargo fmt` |
| **Server run** | `cd server && cargo run` |
| **iOS tests** | Xcode: ⌘U or `xcodebuild test` |
| **Android tests** | `cd android && ./gradlew test` |
| **Website dev** | `cd website && npm run dev` |
| **Website build** | `cd website && npm run build` |

## REST API Reference

```
POST   /auth/send-code            — Send 6-digit verification code to email
POST   /auth/verify                — Verify code → JWT
POST   /teams                      — Register team
GET    /teams/:invite_code         — Resolve invite → team name + ID
POST   /teams/:id/join             — Join team
DELETE /teams/:id/members/:email   — Remove member (leader only)
POST   /push/register              — Register push token
DELETE /account                    — GDPR erasure
WS     /sync                       — E2E encrypted envelope relay
```
