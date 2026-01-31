//! FFI bindings for interactions-core
//!
//! This crate provides FFI bindings for the interactions-core library,
//! allowing Flutter to use the Rust business logic via flutter_rust_bridge.

// Allow flutter_rust_bridge's internal cfg flags
#![allow(unexpected_cfgs)]

mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. */

pub mod api;

// Re-export for flutter_rust_bridge
pub use api::*;
