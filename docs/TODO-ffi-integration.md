# TODO: Complete flutter_rust_bridge FFI Integration

## Summary

The Rust FFI infrastructure is set up, but the Dart bindings need to be generated locally where Flutter SDK is available.

## Background

The code duplication evaluation identified that Dart models were duplicating Rust core models. The solution is to use `flutter_rust_bridge` to generate Dart FFI bindings from the Rust code, eliminating duplication.

**Completed:**
- [x] Created `rust/ffi/` crate with FFI-safe API (`rust/ffi/src/api.rs`)
- [x] Added `flutter_rust_bridge.yaml` configuration
- [x] Updated `CLAUDE.md` with architecture guidelines
- [x] Configured `flutter_rust_bridge_codegen` (requires local Flutter SDK to run)

**Remaining:**
- [ ] Generate Dart FFI bindings
- [ ] Remove manual Dart model implementations
- [ ] Update Flutter imports to use generated bindings
- [ ] Test the integration

## Steps to Complete

### 1. Generate FFI Bindings

```bash
cd /path/to/interactions.work
flutter_rust_bridge_codegen generate
```

This will generate files in `flutter/lib/src/rust/`:
- `frb_generated.dart` - Main generated bindings
- `frb_generated.io.dart` - Platform-specific IO implementation
- `frb_generated.web.dart` - Web implementation (if enabled)

### 2. Update Rust FFI lib.rs

After generation, update `rust/ffi/src/lib.rs` to include the generated module:

```rust
mod frb_generated;
pub mod api;
```

### 3. Remove Manual Dart Models

Delete or replace `flutter/lib/src/rust/models.dart` - the generated bindings will provide these types.

### 4. Update Flutter Imports

Update `flutter/lib/models/models.dart` to export from the generated bindings:

```dart
// Generated FFI bindings from Rust core
export '../src/rust/frb_generated.dart'
    show
        Credentials,
        MemberCredentials,
        Team,
        TeamConfig,
        PublishConfig,
        WebhookConfig,
        LintingConfig,
        BackupConfig,
        Member,
        Interaction,
        InteractionKind,
        Objective,
        KeyResult,
        OkrVisibility;

// Flutter-only models
export 'github_user.dart';
export 'github_repository.dart';
```

### 5. Add flutter_rust_bridge Dependency

Add to `flutter/pubspec.yaml`:

```yaml
dependencies:
  flutter_rust_bridge: ^2.0.0
```

Then run:
```bash
cd flutter && flutter pub get
```

### 6. Configure Native Library Loading

Update `flutter/lib/main.dart` to initialize the Rust library:

```dart
import 'src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}
```

### 7. Build Native Libraries

For each platform:

```bash
# Android (requires cargo-ndk)
cargo install cargo-ndk
cd rust/ffi
cargo ndk -t arm64-v8a -t armeabi-v7a -o ../../flutter/android/app/src/main/jniLibs build --release

# iOS (requires cargo-lipo)
cargo install cargo-lipo
rustup target add aarch64-apple-ios x86_64-apple-ios
cd rust/ffi
cargo lipo --release
```

Or use flutter_rust_bridge's integrated build system.

### 8. Test

```bash
# Rust tests
cargo test --workspace

# Flutter tests
cd flutter && flutter test

# Run the app
cd flutter && flutter run
```

## Files Reference

| File | Purpose |
|------|---------|
| `flutter_rust_bridge.yaml` | Codegen configuration |
| `rust/ffi/src/api.rs` | Rust FFI API (input for codegen) |
| `rust/ffi/Cargo.toml` | FFI crate with cdylib/staticlib |
| `flutter/lib/src/rust/` | Generated Dart bindings (output) |

## Troubleshooting

### Codegen fails with "Dart/Flutter toolchain not available"
Ensure Flutter SDK is installed and `flutter` is in your PATH:
```bash
flutter --version
dart --version
```

### Codegen fails with parse errors
Check that `rust/ffi/src/api.rs` compiles:
```bash
cargo check --package interactions-ffi
```

### Native library not found at runtime
Ensure the native library is built and placed in the correct location for each platform.

## Related Documentation

- Evaluation: `docs/code-duplication-evaluation.md`
- Architecture: See `CLAUDE.md` section "Architecture: Rust Core as Single Source of Truth"
- flutter_rust_bridge docs: https://cjycode.com/flutter_rust_bridge/
