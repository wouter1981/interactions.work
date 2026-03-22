# interactions.work v1 — Design Specification

## Overview

**interactions.work** is a mobile app for any group of humans to strengthen how they work together through shared values, appreciation, feedback, and goals. It serves professional teams, sports teams, volunteer groups, open source projects, and cross-organization collaborations equally.

The app is device-first: data lives on the user's phone, synced between team members via end-to-end encrypted relay. The server never sees interaction content.

### Core Philosophy

- Focus on the positive: kudos, appreciation, recognition
- Don't hide from the hard parts: feedback, apologies, difficult conversations
- Soft skills over hard metrics
- Private by default, intentional sharing
- The interactions are the product, not the team type

## Platforms

| Component | Technology | Notes |
|-----------|------------|-------|
| iOS App | Swift / SwiftUI | Native, minimum iOS 17 |
| Android App | Kotlin / Jetpack Compose | Native, minimum API 28 (Android 9) |
| Marketing Website | Astro (static) | Hosted on Cloudflare Pages |
| Relay Server | Rust (Axum) | Hetzner VPS, EU |
| Database | PostgreSQL | On same Hetzner VPS |
| Email | Resend | Transactional magic links only |
| Push | APNs (iOS) + FCM (Android) | Content-free notifications |

### Protocol-Driven Development

Both native apps implement the same protocol specification independently. There is no shared library or cross-platform framework. The protocol spec (this document + wire format appendix) is the contract. Interoperability tests verify both implementations speak the same language.

This approach is chosen because:
- P2P relay sync touches low-level platform APIs where cross-platform abstractions become leaky
- Native UI produces apps that feel right on each platform
- Two codebases can be developed in parallel by independent agents
- The protocol spec gives each implementation a clear, testable contract

## Pricing

| Tier | Price | Features |
|------|-------|----------|
| **Free** | €0 forever | All core features, unlimited members, P2P encrypted sync |
| **Pro** | €10/month flat per team | Cloud sync & backup, analytics & insights, priority support (features rolled out incrementally post-launch) |
| **Community** | €0 (Pro features) | For volunteer groups and community organizations |

Pro pricing is per-team, not per-user. A team of 5 and a team of 50 pay the same €10/month.

Community tier is Pro features at €0 for non-commercial groups. Team type (professional / community / volunteer) is set during team creation.

**v1 Pro scope:** In v1, Pro unlocks the subscription flag and team type designation. Cloud sync, analytics, and other Pro-exclusive features are delivered incrementally in subsequent releases. Pro subscribers at launch get early-adopter pricing locked in and priority support. The v1 value proposition for Pro is supporting the project + getting cloud features as they ship.

## Data Model

### Team

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| name | String | Team display name |
| vision | String? | What the team aims to achieve |
| invite_code | String | Short code for invite links |
| created_at | DateTime | |

A team has many ManifestoValues, Members, and TeamObjectives.

### ManifestoValue

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| team_id | UUID | FK → Team |
| title | String | e.g. "Trust", "Vulnerability", "Fearless" |
| description | String? | Explanation of what this value means |
| emoji | String? | Visual identifier, e.g. "🤝" |

Manifesto values are structured, not free text. Each value is a discrete entity that kudos and OKRs can reference. This makes the manifesto actionable — not a document on a wall, but a living part of daily interactions.

Leaders create and edit manifesto values. All members see them. Always syncs.

### Member

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| team_id | UUID | FK → Team |
| email | String | Identity + notifications |
| display_name | String | Shown in the app |
| avatar | Data? | Profile image |
| role | Enum | `leader` or `member` |
| joined_at | DateTime | |

A user can be a member of multiple teams (different Member records per team, same email). Leaders can create/edit the manifesto, manage members, and create team objectives. Members can send interactions and manage their own objectives.

Always syncs to all team members.

### Interaction

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| team_id | UUID | FK → Team |
| kind | Enum | `kudos` or `feedback` |
| from | UUID | FK → Member (sender) |
| to | [UUID] | FK → Member (recipients, one or more) |
| message | String | The content |
| value_id | UUID? | FK → ManifestoValue (for kudos: "Thanks for showing Trust 🤝") |
| visibility | Enum | `team` or `private` |
| created_at | DateTime | |

Interactions are append-only — once created, they cannot be edited or deleted. This ensures the integrity of the appreciation and feedback record.

- **Kudos** (visibility: team) → syncs to all team members
- **Kudos** (visibility: private) → syncs to recipient only (a quiet "thank you")
- **Feedback** (visibility: private) → syncs to recipient only (default)
- **Feedback** (visibility: team) → syncs to all (for open team discussions)

### TeamObjective

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| team_id | UUID | FK → Team |
| title | String | The objective |
| description | String? | Context and detail |
| value_id | UUID? | FK → ManifestoValue (optional link to team value) |
| quarter | String? | e.g. "2026-Q2" |
| created_by | UUID | FK → Member (must be a leader) |
| key_results | [TeamKeyResult] | Embedded |

Always syncs to all team members. Leaders create, members contribute via assigned key results.

### TeamKeyResult

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| description | String | What to achieve |
| progress | Float | 0.0 to 1.0 |
| assignee | UUID? | FK → Member (optional, who owns this KR) |
| note | String? | Progress update note |

Assignees update their own key result progress. Progress conflict resolution: highest value wins (you can't un-achieve progress).

### PersonalObjective

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| owner | UUID | FK → Member |
| team_id | UUID? | FK → Team (optional — can exist without a team) |
| title | String | The objective |
| description | String? | |
| value_id | UUID? | FK → ManifestoValue (when tied to a team) |
| quarter | String? | e.g. "2026-Q2" |
| visibility | Enum | `shared` or `private` |
| key_results | [PersonalKeyResult] | Embedded |

- Private → stays on device, never syncs
- Shared → syncs to all team members (read-only for others)

In v1, personal objectives require a team context (`team_id` is required) so they can reference manifesto values. Team-less personal objectives (standalone goal-setting before joining a team) are deferred to a future release.

### PersonalKeyResult

| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| description | String | What to achieve |
| progress | Float | 0.0 to 1.0 |
| note | String? | Self-reflection note |

Self-assessed, self-owned. No one else can update your personal key results.

## Sync Rules

| Entity | Syncs to | Who writes |
|--------|----------|------------|
| Team, ManifestoValue | All members | Leaders only |
| Member | All members | Self (own profile) |
| Interaction (team visibility) | All members | Any member |
| Interaction (private visibility) | Recipient only | Sender |
| TeamObjective + TeamKeyResult | All members | Leaders create, assignees update KR progress |
| PersonalObjective (shared) | All members | Owner only |
| PersonalObjective (private) | Never | Owner only |

## Backend Architecture

### Relay Server

A single Rust service (Axum framework) running on a Hetzner VPS in the EU. The server has three responsibilities:

1. **Team registry** — create teams, resolve invite codes, manage membership
2. **E2E encrypted message relay** — receive encrypted envelopes from one device, deliver to other team members via WebSocket
3. **Authentication** — email magic link verification, JWT session tokens

The server is deliberately minimal. It never sees interaction content, manifesto text, OKR details, or any meaningful user data. All content is end-to-end encrypted on-device before being sent through the relay.

### REST API

```
POST   /auth/magic-link       — Send verification email
POST   /auth/verify            — Verify code, return JWT
POST   /teams                  — Register team ID + invite code
GET    /teams/:invite_code     — Resolve invite → team name + ID
POST   /teams/:id/join         — Register member email to team
POST   /push/register          — Register device for push notifications
DELETE /account                — Delete all user data (GDPR erasure)
```

All endpoints except `/auth/magic-link` and `/teams/:invite_code` require JWT authentication.

### WebSocket — /sync

Connection flow:
1. Client connects with JWT token and team_id
2. Server validates membership
3. Client sends/receives encrypted envelopes
4. On disconnect, server queues incoming envelopes for offline delivery (30-day TTL)
5. If recipient is offline, server triggers a content-free push notification ("You have new activity")

### Database Schema (PostgreSQL)

```sql
-- What the server stores
teams (id, name, invite_code, team_type, created_at)
team_members (team_id, email, joined_at)
users (email, created_at)
sessions (token_hash, email, expires_at)
envelope_queue (id, team_id, sender_id, recipient_id, encrypted_payload, created_at, expires_at)
push_tokens (email, platform, token, created_at)
```

That's the entire database. No content tables.

## Sync Protocol

### Key Exchange

**Team creation:**

1. Team creator generates an asymmetric keypair (X25519) on-device
2. Team creator generates the team's shared symmetric key (AES-256-GCM) and stores it locally
3. Public key is registered with the relay server

**When a new member joins:**

1. New member generates an asymmetric keypair (X25519) on-device
2. Public key is sent to the team via the relay (unencrypted — it's a public key)
3. An existing team member (typically the inviter, who must be online) encrypts the team's shared symmetric key with the new member's public key and sends it via the relay
4. New member decrypts the team key and stores it locally
5. All subsequent messages are encrypted with the team's shared key

For private interactions (visibility: private), the sender encrypts with the recipient's individual public key instead of the team key. Only the recipient can decrypt.

**Key rotation on member removal (v1 limitation):**

In v1, key rotation does NOT happen when a member is removed. The removed member retains the old team key and could theoretically decrypt messages sent before their removal. This is an accepted limitation for v1 — the attack surface is low because the removed member would also need access to the relay to intercept new envelopes, which requires a valid JWT they no longer have.

Post-v1, key rotation on member removal should be implemented: generate a new team symmetric key, distribute it to all remaining members via their individual public keys, and mark old envelopes as using the previous key generation.

### Envelope Format

Every sync message is wrapped in an envelope:

```json
{
  "envelope_id": "uuid",
  "team_id": "uuid",
  "sender_id": "uuid",
  "timestamp": 1774172000,
  "recipients": "all" | ["member-id-1", "member-id-2"],
  "payload": "base64-encoded-encrypted-blob"
}
```

The server sees: envelope_id, team_id, sender_id, timestamp, recipients.
The server cannot see: payload content.

**Encryption rule:** When `recipients` is `"all"`, the payload is encrypted with the team's shared symmetric key (any team member can decrypt). When `recipients` is an array of member IDs, the payload is encrypted individually with each recipient's public key (only those specific members can decrypt). This maps directly to the visibility model: team-visible content uses the team key, private content uses individual keys.

### Payload Format (decrypted on device)

```json
{
  "action": "create" | "update" | "delete",
  "entity": "team" | "manifesto_value" | "member" | "interaction" | "team_objective" | "personal_objective",
  "data": { },
  "version": 1
}
```

The `data` field contains the full entity as defined in the data model section.

### Conflict Resolution

| Entity | Strategy | Rationale |
|--------|----------|-----------|
| Team, ManifestoValue | Last-write-wins (by timestamp) | Leaders rarely edit concurrently |
| Member profile | Last-write-wins | You only edit your own profile |
| Interaction | Append-only | Kudos and feedback are immutable once sent |
| TeamObjective | Last-write-wins | Leaders coordinate edits |
| TeamKeyResult progress | Highest value wins | You can't un-achieve progress |
| PersonalObjective | Last-write-wins | Only one owner, one device |

### Offline Support

All actions work offline — changes queue locally in SQLite. On reconnect:

1. Device sends all queued envelopes in timestamp order
2. Server delivers any stored envelopes from other members
3. Device applies received changes using conflict resolution rules
4. Queue is cleared

The app is always usable. Sync happens when connectivity is available.

## App Structure

### Onboarding Flow

1. **Welcome** — 3 slides explaining the value proposition
2. **Email** — enter email, receive magic link
3. **Profile** — set display name and optional avatar
4. **Get Started** — create a team or join via invite link

### Main Navigation (4 tabs)

**Home** — Team feed showing recent kudos and shared interactions. Team manifesto always visible and tappable. Quick action button to send kudos. Active team members shown.

**Interact** — Send kudos (pick person → pick manifesto value → write message). Give feedback (private by default). View received interactions. Full interaction history.

**Goals** — Two sections: "Our Goals" (team OKRs created by leaders) and "My Goals" (personal OKRs). Progress tracking per key result. Link to manifesto values.

**Profile** — Display name and avatar. Switch between teams. Notification settings. Privacy controls and data export (GDPR). Pro upgrade path.

### Team Management (Leader extras)

- **Manifesto Editor** — add/edit/reorder values, set emoji, write descriptions
- **Members** — invite via link, view member list, promote to leader, remove
- **Team Settings** — name, vision, team type (professional/community/volunteer), Pro subscription, delete team

### Invite Flow

A single invite link handles all scenarios:

- **Mobile with app** → deep link opens the app, joins the team
- **Mobile without app** → redirect to App Store / Play Store, deferred deep link joins after install
- **Desktop** → interactions.work/join/:code shows team name + QR code to scan with phone

## Marketing Website

### Structure

Static one-pager built with Astro, hosted on Cloudflare Pages (free tier).

1. **Hero** — tagline, value proposition, App Store + Play Store badges
2. **CTA** — "Start Free Now — free forever" immediately below hero
3. **Features** — 3 blocks: shared values (manifesto), appreciate & grow (kudos + feedback), track goals together (OKRs)
4. **Use cases** — dev teams, sports teams, volunteer groups, cross-org collaborations
5. **Privacy pitch** — device-first, E2E encrypted, zero-knowledge server, GDPR compliant, EU hosted
6. **Pricing** — Free (€0 forever) / Pro (€10/mo flat) / Community (€0, Pro features)
7. **Download CTA** — repeated store badges
8. **Footer** — privacy policy, terms of service, GDPR info, contact

### Invite Link Handler

The URL `interactions.work/join/:code` is the only dynamic route. Implemented as a Cloudflare Worker or served by the relay server:

- Resolves invite code to team name via relay API
- On mobile: redirects to app (deep link) or store (with deferred deep link)
- On desktop: renders page with team name and QR code pointing to the same invite URL

## GDPR Compliance

### Data Minimization

The server stores the minimum required for operation:

| Data | Purpose | Retention |
|------|---------|-----------|
| Email address | Auth + team membership | Until account deletion |
| Team ID + name | Team registry + invite resolution | Until team deletion |
| Encrypted envelopes | Offline delivery queue | 30 days, then purged |
| Push tokens | Notification delivery | Until device unregisters |
| JWT sessions | Authentication | 30-day expiry |

No interaction content, manifesto text, OKR details, or usage analytics are stored on the server.

### User Rights

- **Right to erasure** — `DELETE /account` removes all user data: email, team memberships, queued envelopes, push tokens, sessions
- **Data portability** — in-app export of all local data in JSON format
- **Consent** — explicit opt-in for email notifications and push notifications
- **Transparency** — privacy policy clearly states what is collected and why

### Infrastructure

- All server infrastructure in the EU (Hetzner, Germany)
- No data transfers outside the EU
- Resend configured for EU sending
- No third-party analytics or tracking on the website or in the app

## Technology Summary

### iOS App
- Swift 5.9+, SwiftUI
- Local storage: SQLite (via GRDB or Swift Data)
- Encryption: CryptoKit (X25519 + AES-256-GCM)
- Networking: URLSession (REST) + URLSessionWebSocketTask (sync)
- Push: APNs

### Android App
- Kotlin, Jetpack Compose
- Local storage: Room (SQLite)
- Encryption: Tink or libsodium (X25519 + AES-256-GCM)
- Networking: Ktor or OkHttp (REST) + OkHttp WebSocket (sync)
- Push: FCM

### Relay Server
- Rust, Axum framework
- PostgreSQL (via sqlx)
- WebSocket (tokio-tungstenite)
- Resend SDK for transactional email
- Deployed on Hetzner VPS (EU)

### Marketing Website
- Astro (static site generator)
- Hosted on Cloudflare Pages (free tier)
- Invite link handler: Cloudflare Worker or relay server route

## Repository Structure

```
interactions.work/
├── docs/
│   ├── protocol/              # Wire format, sync protocol spec
│   ├── superpowers/specs/     # This design document
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

## Out of Scope for v1

The following features are intentionally deferred:

- **Check-ins & Pulse** — regular prompts and mood tracking
- **Retrospectives** — structured async team reflections
- **Interaction Journal** — private personal log
- **Web portal** — admin dashboard for Pro teams
- **Pro cloud sync** — server-side data storage for Pro tier (v1 Pro is just the subscription flag; cloud features come in v2)
- **Analytics & insights** — team interaction patterns, value usage stats
- **In-app billing** — App Store / Play Store subscription management (can use manual Stripe checkout initially)
