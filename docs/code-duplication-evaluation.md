# Code Duplication Evaluation: Dart vs Rust

This document evaluates code duplication between the Flutter/Dart and Rust codebases, identifying opportunities to use the Rust core library via FFI rather than maintaining parallel implementations.

## Executive Summary

There is **significant duplication** in data models and authentication logic between the two codebases. The Rust core library provides a solid foundation that could be exposed to Flutter via FFI, reducing maintenance burden and ensuring consistency.

| Area | Rust Core | Flutter/Dart | Duplication Level |
|------|-----------|--------------|-------------------|
| Team Model | ✓ | ✓ | **High** |
| TeamConfig | ✓ | ✓ | **High** |
| Credentials/Auth | ✓ | ✓ | **High** |
| Member Model | ✓ | ✗ | None |
| Interaction Model | ✓ | ✗ | None |
| OKR Models | ✓ | ✗ | None |
| Storage/File Ops | ✓ | Partial | Medium |
| GitHub API | ✗ | ✓ | None |

## Detailed Analysis

### 1. High Duplication: Data Models

#### Team Model

**Rust** (`rust/core/src/models/team.rs`):
```rust
pub struct Team {
    pub name: String,
    pub manifesto: Option<String>,
    pub vision: Option<String>,
    pub leaders: Vec<String>,
    pub members: Vec<String>,
}
```

**Dart** (`flutter/lib/models/team.dart`):
```dart
class Team {
  final String name;
  final String? manifesto;
  final String? vision;
  final List<String> leaders;
  final List<String> members;
}
```

Both implementations:
- Have identical fields and types
- Include `isLeader(email)` and `isMember(email)` helper methods
- Support YAML serialization/deserialization
- Use builder/copyWith patterns

#### TeamConfig Model

**Rust** (`rust/core/src/models/config.rs`):
```rust
pub struct TeamConfig {
    pub publish: PublishConfig,
    pub webhooks: Option<WebhookConfig>,
    pub linting: LintingConfig,
    pub backup: BackupConfig,
}
```

**Dart** (`flutter/lib/models/team.dart`):
```dart
class TeamConfig {
  final PublishConfig publish;
  final LintingConfig linting;
  final BackupConfig backup;
}
```

Both have nested configs for publish paths, linting settings, and backup configuration with matching field structures.

#### Credentials/Authentication

**Rust** (`rust/core/src/auth.rs`):
```rust
pub struct Credentials {
    salt: String,      // 16 bytes, hex-encoded
    pincode_hash: String,  // SHA256, hex-encoded
}

impl Credentials {
    pub fn new(pincode: &str) -> Self { /* SHA256(salt + pincode) */ }
    pub fn verify(&self, pincode: &str) -> bool { /* constant-time compare */ }
}
```

**Dart** (`flutter/lib/models/credentials.dart`):
```dart
class Credentials {
  final String salt;
  final String pincodeHash;

  factory Credentials.fromPincode(String pincode) { /* SHA256(salt + pincode) */ }
  bool verify(String pincode) { /* constant-time compare */ }
}
```

Both implementations:
- Use 16-byte random salt
- Hash with SHA256(salt + pincode)
- Use constant-time comparison for security
- Serialize to identical YAML format

**This is a critical area for sharing** - authentication logic must be identical across platforms to read/write the same credential files.

### 2. Medium Duplication: Storage Operations

**Rust** (`rust/core/src/storage/mod.rs`):
- Complete `TeamStorage` struct with:
  - Directory path management (`.team/`, `.personal/`, `members/{email}/`)
  - File I/O operations (load/save team, config, manifesto, vision, credentials)
  - Directory initialization
  - Member listing

**Dart** (`flutter/lib/providers/team_provider.dart`):
- Partial implementation via GitHub API:
  - Knows directory structure
  - Creates `.team/` files during team setup
  - Reads config and team YAML files

The Dart implementation duplicates the **knowledge of directory structure** but uses GitHub's REST API for file operations rather than local filesystem access.

### 3. Models Only in Rust Core

These models exist in Rust but haven't been implemented in Dart yet:

#### Member Model (`rust/core/src/models/member.rs`)
```rust
pub struct Member {
    pub email: String,
    pub name: Option<String>,
    pub bio: Option<String>,
    pub timezone: Option<String>,
}
```

#### Interaction Model (`rust/core/src/models/interaction.rs`)
```rust
pub enum InteractionKind {
    Appreciation, Feedback, Apology, CheckIn, Retrospective
}

pub struct Interaction {
    pub id: String,
    pub kind: InteractionKind,
    pub from: String,
    pub with: Vec<String>,
    pub note: String,
    pub timestamp: DateTime<Utc>,
    pub shared: bool,
}
```

#### OKR Models (`rust/core/src/models/okr.rs`)
```rust
pub struct KeyResult {
    pub description: String,
    pub progress: f64,
    pub notes: Option<String>,
}

pub struct Objective {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub key_results: Vec<KeyResult>,
    pub visibility: OkrVisibility,
    pub owner: String,
    pub quarter: Option<String>,
}
```

## Recommendations

### Priority 1: Share via FFI (High Impact)

| Component | Benefit | Complexity |
|-----------|---------|------------|
| **Credentials** | Security-critical, must be identical | Low |
| **Team/TeamConfig** | Core domain model, avoid drift | Low |
| **Member** | Flutter needs this for future features | Low |

**Approach**: Create Rust FFI bindings using `flutter_rust_bridge` or `uniffi-rs`:

```
rust/core/
├── src/
│   ├── ffi/           # New FFI module
│   │   ├── mod.rs
│   │   ├── models.rs  # FFI-safe model wrappers
│   │   └── auth.rs    # Auth function exports
```

### Priority 2: Share When Implementing Features

| Component | When to Share |
|-----------|---------------|
| **Interaction** | When building kudos/feedback UI in Flutter |
| **OKR** | When building OKR management in Flutter |
| **Storage paths** | When Flutter needs offline/local storage |

### Priority 3: Keep Platform-Specific

| Component | Reason |
|-----------|--------|
| **GitHub API** | Flutter has excellent HTTP/OAuth libraries |
| **UI State** | Provider pattern works well for Flutter |
| **TUI rendering** | Ratatui is Rust-only |

## Implementation Path

### Phase 1: FFI Infrastructure

1. Add `flutter_rust_bridge` to the project
2. Create FFI module in `rust/core/src/ffi/`
3. Generate Dart bindings
4. Add `interactions_core` dependency to Flutter

### Phase 2: Migrate Credentials

1. Export `Credentials` struct via FFI
2. Replace `flutter/lib/models/credentials.dart` with FFI calls
3. Verify YAML compatibility (read Rust-created files in Dart and vice versa)

### Phase 3: Migrate Data Models

1. Export `Team`, `TeamConfig`, `Member` via FFI
2. Replace Dart models with FFI wrappers
3. Keep YAML serialization in Rust, expose to Dart

### Phase 4: Add New Features via Core

1. Implement `Interaction` operations in Rust core
2. Expose via FFI for Flutter's kudos/feedback features
3. Same approach for OKRs

## Code to Remove After Migration

Once FFI is implemented, the following Dart files can be simplified or removed:

```
flutter/lib/models/
├── credentials.dart    # Replace with FFI calls
├── team.dart          # Replace Team/TeamConfig with FFI
└── models.dart        # Update barrel exports

# ~400 lines of Dart code can be replaced with ~50 lines of FFI wrappers
```

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| FFI complexity | Use `flutter_rust_bridge` for automatic binding generation |
| Build complexity | CI already builds both; add combined builds |
| Mobile binary size | Rust core is small (~200KB); minimal impact |
| Debugging | Keep FFI layer thin; business logic in Rust |

## Summary Table

| Decision | Recommendation |
|----------|----------------|
| Credentials/Auth | **Move to Rust core via FFI** |
| Team/TeamConfig models | **Move to Rust core via FFI** |
| Member model | **Use Rust core via FFI** |
| Interaction model | **Use Rust core via FFI** (when building feature) |
| OKR models | **Use Rust core via FFI** (when building feature) |
| GitHub API service | Keep in Dart |
| State management | Keep Provider in Dart |
| YAML serialization | Consolidate in Rust core |

## Appendix: File Reference

### Rust Core Files
- `rust/core/src/models/team.rs` - Team model
- `rust/core/src/models/config.rs` - TeamConfig model
- `rust/core/src/models/member.rs` - Member model
- `rust/core/src/models/interaction.rs` - Interaction model
- `rust/core/src/models/okr.rs` - OKR models
- `rust/core/src/auth.rs` - Credentials authentication
- `rust/core/src/storage/mod.rs` - File storage operations

### Flutter/Dart Files (with duplication)
- `flutter/lib/models/team.dart` - Duplicates Team, TeamConfig
- `flutter/lib/models/credentials.dart` - Duplicates Credentials auth
- `flutter/lib/providers/team_provider.dart` - Duplicates directory structure knowledge
