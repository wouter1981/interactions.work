//! interactions-core: Core library for interactions.work
//!
//! This library provides the domain models and business logic for
//! personal and team development goals across organizations and communities.

pub mod auth;
pub mod error;
pub mod models;
pub mod storage;

pub use auth::{Credentials, MemberCredentials};
pub use error::{Error, Result};
pub use models::*;
pub use storage::TeamStorage;
