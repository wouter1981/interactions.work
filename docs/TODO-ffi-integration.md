# flutter_rust_bridge FFI Integration

## Status: Working

The FFI integration is now functional with `flutter_rust_bridge` v2.11.1.

## Summary

- Generated Dart FFI bindings in `flutter/lib/src/rust/`
- All tests pass (42 Rust, 18 Flutter)
- Manual Dart models kept for now until migration is complete

## Build Requirement

On Linux, you may need to set `CPATH` for `ffigen` to find C headers:

```bash
CPATH="/usr/lib/gcc/x86_64-pc-linux-gnu/15.2.1/include" flutter_rust_bridge_codegen generate
```

Or add to your shell profile for convenience.

## What's Completed

- [x] Created `rust/ffi/` crate with FFI-safe API (`rust/ffi/src/api.rs`)
- [x] Added `flutter_rust_bridge.yaml` configuration
- [x] Updated `CLAUDE.md` with architecture guidelines
- [x] Configured `flutter_rust_bridge_codegen` v2.11.1
- [x] Generated Dart FFI bindings in `flutter/lib/src/rust/`
- [x] Tests pass for both Rust (42 tests) and Flutter (18 tests)

## Remaining Tasks

- [ ] Migrate Flutter app to use generated FFI types instead of manual models
- [ ] Remove manual Dart models in `flutter/lib/src/rust/models.dart`
- [ ] Update Flutter imports throughout the app
- [ ] Build and link the native library for each platform (Linux, Android, iOS)

## Generated Files

| File | Purpose |
|------|---------|
| `flutter/lib/src/rust/api.dart` | Generated Dart API types |
| `flutter/lib/src/rust/api.freezed.dart` | Freezed implementations |
| `flutter/lib/src/rust/frb_generated.dart` | Bridge implementation |
| `flutter/lib/src/rust/frb_generated.io.dart` | Platform-specific FFI bindings |

## Configuration Files

| File | Purpose |
|------|---------|
| `flutter_rust_bridge.yaml` | Codegen configuration |
| `rust/ffi/src/api.rs` | Rust FFI API |
| `rust/ffi/Cargo.toml` | FFI crate (cdylib/staticlib) |

## Regenerating Bindings

```bash
# Set CPATH if needed (Linux)
export CPATH="/usr/lib/gcc/x86_64-pc-linux-gnu/15.2.1/include"

# Generate bindings
flutter_rust_bridge_codegen generate

# Generate freezed classes
cd flutter && dart run build_runner build --delete-conflicting-outputs
```

## Related Documentation

- Architecture: See `CLAUDE.md` section "Architecture: Rust Core as Single Source of Truth"
- flutter_rust_bridge docs: https://cjycode.com/flutter_rust_bridge/
