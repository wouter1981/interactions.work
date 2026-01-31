# TODO: Complete flutter_rust_bridge FFI Integration

## Summary

The Rust FFI API is set up, but code generation has compatibility issues with Dart 3.10+/Flutter 3.38+.

**Current Status**: Using manual Dart models that mirror the Rust API. This works well and all tests pass.

## Background

The code duplication evaluation identified that Dart models were duplicating Rust core models. The solution is to use `flutter_rust_bridge` to generate Dart FFI bindings from the Rust code, eliminating duplication.

## What's Completed

- [x] Created `rust/ffi/` crate with FFI-safe API (`rust/ffi/src/api.rs`)
- [x] Added `flutter_rust_bridge.yaml` configuration
- [x] Updated `CLAUDE.md` with architecture guidelines
- [x] Configured `flutter_rust_bridge_codegen`
- [x] Created manual Dart models in `flutter/lib/src/rust/models.dart`
- [x] Tests pass for both Rust (42 tests) and Flutter (18 tests)

## Blocked

- [ ] Generate Dart FFI bindings - **Blocked by Dart SDK compatibility**
- [ ] Remove manual Dart model implementations
- [ ] Update Flutter imports to use generated bindings

### Compatibility Issue

The `flutter_rust_bridge_codegen` generates code that's incompatible with Dart 3.10+:

```
error - lib/src/rust/frb_generated.io.dart:1592:12 - Fields in struct classes can't
have the type 'bool'. They can only be declared as 'int', 'double', 'Array', 'Pointer',
or subtype of 'Struct' or 'Union'.
```

This is a known issue between flutter_rust_bridge and newer Dart SDK versions.

## Current Working Approach

The manual Dart models in `flutter/lib/src/rust/models.dart`:
- Mirror the Rust API exactly (same method names, same behavior)
- Are well-tested (18 passing tests)
- Can be easily replaced with generated bindings when compatibility is fixed

## To Resolve When flutter_rust_bridge Updates

When a compatible version of flutter_rust_bridge is released:

1. Update `flutter/pubspec.yaml`:
   ```yaml
   flutter_rust_bridge: ^2.x.x  # version with Dart 3.10+ support
   ```

2. Regenerate bindings:
   ```bash
   flutter_rust_bridge_codegen generate
   ```

3. Update `flutter/lib/models/models.dart` to use generated types

4. Remove `flutter/lib/src/rust/models.dart`

5. Run tests to verify

## Files Reference

| File | Purpose |
|------|---------|
| `flutter_rust_bridge.yaml` | Codegen configuration |
| `rust/ffi/src/api.rs` | Rust FFI API (ready for codegen) |
| `rust/ffi/Cargo.toml` | FFI crate with cdylib/staticlib |
| `flutter/lib/src/rust/models.dart` | Manual Dart models (current solution) |

## Related Documentation

- Evaluation: `docs/code-duplication-evaluation.md`
- Architecture: See `CLAUDE.md` section "Architecture: Rust Core as Single Source of Truth"
- flutter_rust_bridge docs: https://cjycode.com/flutter_rust_bridge/
- flutter_rust_bridge issues: https://github.com/aspect-build/rules_js/issues
