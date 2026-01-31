//! FFI bindings for interactions-core
//!
//! This crate provides FFI bindings for the interactions-core library,
//! allowing Flutter to use the Rust business logic via flutter_rust_bridge.
//!
//! **Note**: The FFI code generation (flutter_rust_bridge_codegen) has compatibility
//! issues with Dart 3.10+. For now, use the manual Dart models in
//! `flutter/lib/src/rust/models.dart` which provide the same API.

pub mod api;

// Re-export for flutter_rust_bridge
pub use api::*;
