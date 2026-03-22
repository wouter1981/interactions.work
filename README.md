# interactions.work

A mobile app for any group of humans to strengthen how they work together through shared values, appreciation, feedback, and goals.

## What is this?

**interactions.work** focuses on **people and their interactions** — not tasks, not metrics, not performance reviews. It serves any team that wants to be intentional about how they collaborate: dev teams, sports teams, volunteer groups, open source projects, and cross-organization collaborations.

### Philosophy

- Focus on the positive: kudos, appreciation, recognition
- Don't hide from the hard parts: feedback, apologies, difficult conversations
- Soft skills over hard metrics
- Private by default, intentional sharing
- The interactions are the product, not the team type

## Features

### Team Manifesto & Vision
Create a team with shared values. Not a document on a wall — each value is a living part of daily interactions that kudos and goals reference.

### Kudos & Appreciation
Send kudos tied to your team's values: *"Thanks for showing Trust."* Quick, lightweight, positive.

### Feedback & Difficult Conversations
Give constructive feedback when it matters. Private by default. The app makes honest conversations natural, not scary.

### Goals (OKRs)
Set team objectives and personal growth goals — both linked to what your team values most. Track progress through self-reflection, not dashboards.

## Technology Stack

| Component | Technology |
|-----------|------------|
| iOS App | Swift / SwiftUI |
| Android App | Kotlin / Jetpack Compose |
| Relay Server | Rust (Axum) |
| Database | PostgreSQL |
| Marketing Website | Astro |
| Sync | E2E encrypted relay over WebSocket |
| Hosting | Hetzner (EU) + Cloudflare Pages |

## Architecture

Device-first, protocol-driven. Both native apps implement the same protocol spec independently. The server is a relay — it never sees your data.

```
┌───────────────────────────────────────────────┐
│              Native Mobile Apps               │
├─────────────────────┬─────────────────────────┤
│  iOS (SwiftUI)      │  Android (Compose)      │
│  Local SQLite       │  Local Room (SQLite)    │
│  CryptoKit (E2E)    │  Tink (E2E)             │
├─────────────────────┴─────────────────────────┤
│         WebSocket (E2E encrypted)             │
├───────────────────────────────────────────────┤
│         Relay Server (Rust/Axum)              │
│  Team registry · Message relay · Auth         │
│  Zero knowledge of content                   │
└───────────────────────────────────────────────┘
```

## Getting Started

### Prerequisites

- Docker (for PostgreSQL)
- Rust (latest stable) — for the relay server
- Node.js 18+ — for the marketing website
- Xcode 15+ — for iOS app
- Android Studio — for Android app

### Run the Server

```bash
# Start PostgreSQL
docker-compose up -d

# Run the relay server
cd server
cp .env.example .env
cargo run
```

The server starts on `http://localhost:3000`. In dev mode, verification codes are logged to the console instead of being emailed.

### Run the Website

```bash
cd website
npm install
npm run dev
```

### Project Structure

```
interactions.work/
├── server/           # Rust relay server (Axum)
├── website/          # Astro marketing site
├── ios/              # Swift/SwiftUI app (planned)
├── android/          # Kotlin/Compose app (planned)
├── tests/interop/    # Cross-platform test vectors
└── docs/
    ├── intent/       # Why the app exists
    ├── protocol/     # Wire format spec
    └── superpowers/  # Design specs and plans
```

## Pricing

| Tier | Price | Description |
|------|-------|-------------|
| **Free** | €0 forever | All features, unlimited members, encrypted P2P sync |
| **Pro** | €10/month flat | Per team, cloud sync & backup (rolling out post-launch) |
| **Community** | €0 | Pro features free for volunteer and community groups |

## Privacy

- **Device-first** — your data lives on your phone
- **End-to-end encrypted** — we can't read your interactions
- **EU hosted** — all infrastructure in Germany (Hetzner)
- **GDPR compliant** — minimal data, full control, right to erasure
- **Zero knowledge** — the server stores team IDs and emails, nothing else

## Contributing

We welcome contributions! Start by reading the intent document at `docs/intent/main.md` and the design spec at `docs/superpowers/specs/`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
