//! FFI bindings for interactions-core
//!
//! This crate provides FFI bindings for the interactions-core library,
//! allowing Flutter to use the Rust business logic via flutter_rust_bridge.

pub mod api;

// Re-export for flutter_rust_bridge
pub use api::*;
