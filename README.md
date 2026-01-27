# interactions.work

An open source application for personal and team development goals across organizations and communities.

## Overview

**interactions.work** focuses on **people and their interactions** - strengthening human relationships, improving collaboration, and developing soft skills. A team can be a sports team, a multi-organization collaboration, or an open source project.

### Philosophy

- Focus on the positive: kudos, appreciation, recognition
- Don't hide from the hard parts: feedback, apologies, difficult conversations
- Soft skills over hard metrics
- Private by default, intentional sharing

## Features

### Teams

Flexible, user-defined groups with:
- **Manifesto**: Behavior norms and cultural principles
- **Vision**: What the team aims to achieve
- **Leaders & Members**: Collaborative structure with clear roles

### Interactions

Logged moments between people - a lightweight journal of meaningful exchanges:
- Structured: Retrospectives, scheduled feedback sessions
- Ad-hoc: Quick kudos, notes after calls, feedback requests
- Types: Appreciation, feedback, apologies, check-ins

### OKRs (Objectives & Key Results)

Personal or team-level goals tied to manifesto principles:
- Shared or private visibility
- Progress measured through self-reflection and peer input

### Pulse

Engagement system with regular prompts for updates, journaling, and feedback requests.

## Technology Stack

| Component | Technology |
|-----------|------------|
| Mobile | Flutter with Material 3 (Android & iOS) |
| TUI | Rust with Ratatui (PowerShell & Bash) |
| Core Logic | Rust (shared via FFI with Flutter) |
| Storage | Git-compatible (local, Google Drive, OneDrive) |
| Data Format | YAML |

## Getting Started

### Prerequisites

- Rust (latest stable)
- Flutter SDK
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/wouter1981/interactions.work.git
cd interactions.work

# Build the Rust core and TUI
cd rust
cargo build --release

# Build the Flutter app
cd ../flutter
flutter pub get
flutter build
```

### Usage

```bash
# Launch interactive TUI
interactions

# CI/CD commands
interactions publish      # Generate markdown files
interactions lint         # Validate .team/ structure
interactions pulse        # Send reminders via webhooks
interactions backup       # Backup to protected branch
```

## Project Structure

```
interactions.work/
├── rust/                       # Rust core library + TUI
│   ├── core/                   # Shared business logic
│   └── tui/                    # Terminal UI (Ratatui)
├── flutter/                    # Mobile app
│   ├── lib/
│   ├── android/
│   └── ios/
└── docs/
```

## Privacy

- Private data encrypted client-side with user's pincode
- `.personal/` folder never leaves the local machine
- Sharing is an explicit action with encrypted storage
- Team content is plain YAML for repo access transparency

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [Documentation](docs/)
- [Issues](https://github.com/wouter1981/interactions.work/issues)
