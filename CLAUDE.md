# CLAUDE.md - AI Assistant Guidelines

This document provides guidance for AI assistants working with the interactions.work codebase.

## Project Overview

**interactions.work** is an open source application for personal and team development goals across organizations and communities. A team can be a sports team, a multi-organization collaboration, or an open source project. The focus is on **people and their interactions** - strengthening human relationships, improving collaboration, and developing soft skills.

### Core Philosophy

- Focus on the positive: kudos, appreciation, recognition
- Don't hide from the hard parts: feedback, apologies, difficult conversations
- Soft skills over hard metrics
- Private by default, intentional sharing

## Core Concepts

### Teams

A team is flexible and user-defined:

- **Name**: Team identifier
- **Manifesto**: Behavior norms and cultural principles the team strives for
- **Vision**: What the team aims to achieve
- **Leaders**: Set the purpose and maintain the manifesto
- **Members**: Join and commit to following the manifesto principles

### Interactions

Logged moments between people - a lightweight journal of meaningful exchanges:

- **Structured**: Retrospectives, scheduled feedback sessions
- **Ad-hoc**: Quick kudos, notes after calls, feedback requests
- **Types**: Appreciation, feedback, apologies, check-ins

### OKRs (Objectives & Key Results)

Based on the OKR framework, tied to manifesto principles:

- **Personal or Team** level
- **Shared or Private** visibility
- Progress measured through self-reflection, peer input, and linked interactions

### Pulse

Engagement system with regular prompts:

- Friday morning updates
- Sunday afternoon journaling
- Interaction logging nudges
- Feedback requests
- (Patterns will evolve as the app grows)

## Technology Stack

| Component | Technology |
|-----------|------------|
| Mobile | Flutter with Material 3 (Android & iOS) |
| TUI | Rust with Ratatui (PowerShell & Bash) |
| Core Logic | Rust (shared via FFI with Flutter) |
| Storage | Git-compatible (local, Google Drive, OneDrive) |
| Data Format | YAML |
| Platforms | GitHub, GitLab, pure Git |

## Repository Structure

### Codebase

```
interactions.work/
├── CLAUDE.md
├── README.md
├── rust/                       # Rust core library + TUI
│   ├── core/                   # Shared business logic
│   ├── tui/                    # Terminal UI (Ratatui)
│   └── Cargo.toml
├── flutter/                    # Mobile app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
└── docs/
```

### Data Storage (.team folder)

```
.team/
├── config.yaml                 # Settings, publish locations, webhooks
├── manifesto.yaml              # Team manifesto (source)
├── vision.yaml                 # Team vision (source)
├── members/
│   └── {email}/
│       ├── profile.yaml
│       └── shared/             # Encrypted content user chose to share
├── team/
│   ├── okrs/                   # Team-level OKRs
│   ├── interactions/           # Team interactions
│   └── retrospectives/
└── drafts/                     # Work in progress

.personal/                      # Gitignored - local only
├── settings.yaml
├── okrs/                       # Private OKRs
├── journal/                    # Personal journal
└── drafts/
```

### Published Output (configurable)

```
/MANIFESTO.md                   # Published from .team/manifesto.yaml
/VISION.md                      # Published from .team/vision.yaml
/okrs/
└── 2026-Q1.md                  # Published team OKRs
```

## Configuration

### .team/config.yaml

```yaml
publish:
  manifesto: /MANIFESTO.md
  vision: /VISION.md
  okrs: /okrs/

webhooks:
  discord: <webhook-url>
  slack: <webhook-url>
  signal: <config>

linting:
  enabled: true
  target_branch: interactions

backup:
  protected_branch: main
```

## Git Workflow

### Branches

| Branch | Protection | Purpose |
|--------|------------|---------|
| `main` | Protected | Settings, published content, backups. Only maintainers. |
| `interactions` | Unprotected | Day-to-day contributions via PRs/MRs |
| Feature branches | None | Drafts and work in progress |

### Workflow

1. Contributors work on feature branches
2. PRs/MRs target the `interactions` branch
3. Linting validates `.team/` structure on PRs
4. Maintainers publish content to `main` and generate markdown files
5. Backups to protected branch triggered by maintainers

## CLI Commands

The TUI runs in both interactive and headless (CI/CD) modes:

```bash
# Interactive mode
interactions              # Launch TUI

# CI/CD commands
interactions publish      # Generate markdown files from .team/ sources
interactions lint         # Validate .team/ structure (for PR checks)
interactions pulse        # Send reminders via configured webhooks
interactions backup       # Backup to protected branch (maintainers)
interactions restore <commit>  # Restore from git history
```

## Privacy & Encryption

| Location | In Repo? | Who Can Read? |
|----------|----------|---------------|
| `.personal/` | No (gitignored) | User only (local) |
| `members/{email}/shared/` | Yes (encrypted) | User only (pincode-derived key) |
| Team content | Yes (plain YAML) | Anyone with repo access |

- Private data encrypted client-side with key derived from user's pincode (seeded hash)
- `.personal/` never leaves the local machine
- Sharing is an explicit action: content moves to `members/{email}/shared/` encrypted

## Development Guidelines

### Branching Strategy

- `main` - Stable releases
- `develop` - Integration branch
- `feature/*` - New features
- `fix/*` - Bug fixes
- `chore/*` - Maintenance tasks

### Code Style

**Rust:**
- Follow Rust 2021 edition idioms
- Use `cargo fmt` before committing
- Use `cargo clippy` for linting
- Aim for zero warnings

**Flutter/Dart:**
- Follow official Dart style guide
- Use `dart format` before committing
- Use `dart analyze` for linting
- Prefer composition over inheritance

### Testing

- Unit tests required for core logic
- Integration tests for git operations
- Widget tests for Flutter UI components
- Aim for 80%+ coverage on core library

```bash
# Rust
cargo test
cargo test --workspace

# Flutter
flutter test
flutter test --coverage
```

### Commit Messages

Follow Conventional Commits:

```
feat: add pulse notification system
fix: correct encryption key derivation
docs: update CLAUDE.md with privacy section
chore: update dependencies
```

## AI Assistant Guidelines

### When Making Changes

1. **Read before modifying** - Understand existing code first
2. **Respect the domain** - This is about human interactions, not task management
3. **Privacy first** - Never expose private data patterns
4. **Keep it simple** - Soft skills don't need complex code
5. **Test thoroughly** - Especially encryption and git operations

### Key Principles

- The manifesto is sacred - it defines team culture
- Interactions are personal - treat logged moments with care
- Encryption must be correct - private means private
- Git is the backend - respect the branching workflow

### Things to Avoid

- Don't leak private content patterns to shared spaces
- Don't skip encryption for "convenience"
- Don't commit directly to `main` or `interactions` branches
- Don't add hard metric tracking - this is about soft skills
- Don't over-engineer - keep the focus on human connection

## Quick Reference

| Task | Command |
|------|---------|
| Run TUI | `interactions` |
| Publish content | `interactions publish` |
| Lint PR | `interactions lint` |
| Send pulse | `interactions pulse` |
| Backup | `interactions backup` |
| Rust tests | `cargo test --workspace` |
| Flutter tests | `flutter test` |
| Format Rust | `cargo fmt` |
| Format Dart | `dart format .` |
