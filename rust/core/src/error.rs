//! Error types for interactions-core

use thiserror::Error;

/// Result type alias for interactions-core operations
pub type Result<T> = std::result::Result<T, Error>;

/// Error types for interactions-core
#[derive(Error, Debug)]
pub enum Error {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("YAML parsing error: {0}")]
    Yaml(#[from] serde_yaml::Error),

    #[error("Team not found: {0}")]
    TeamNotFound(String),

    #[error("Member not found: {0}")]
    MemberNotFound(String),

    #[error("Invalid configuration: {0}")]
    InvalidConfig(String),

    #[error("Storage error: {0}")]
    Storage(String),

    #[error("Authentication failed: {0}")]
    AuthFailed(String),

    #[error("Credentials not found for: {0}")]
    CredentialsNotFound(String),
}
