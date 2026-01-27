//! Interaction model
//!
//! Logged moments between people - a lightweight journal of meaningful exchanges.

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// The kind of interaction
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum InteractionKind {
    /// Kudos, recognition, appreciation
    Appreciation,
    /// Constructive feedback
    Feedback,
    /// Making amends
    Apology,
    /// Regular check-in
    CheckIn,
    /// Retrospective discussion
    Retrospective,
}

impl InteractionKind {
    /// Get a human-readable label for this kind
    pub fn label(&self) -> &'static str {
        match self {
            Self::Appreciation => "Appreciation",
            Self::Feedback => "Feedback",
            Self::Apology => "Apology",
            Self::CheckIn => "Check-in",
            Self::Retrospective => "Retrospective",
        }
    }
}

/// A logged interaction between people
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Interaction {
    /// Unique identifier
    pub id: String,

    /// The kind of interaction
    pub kind: InteractionKind,

    /// Who logged this interaction
    pub from: String,

    /// Who the interaction was with
    pub with: Vec<String>,

    /// Brief description or note
    pub note: String,

    /// When the interaction occurred
    pub timestamp: DateTime<Utc>,

    /// Whether this is shared with the team or private
    #[serde(default)]
    pub shared: bool,
}

impl Interaction {
    /// Create a new interaction
    pub fn new(
        kind: InteractionKind,
        from: impl Into<String>,
        with: Vec<String>,
        note: impl Into<String>,
    ) -> Self {
        Self {
            id: generate_id(),
            kind,
            from: from.into(),
            with,
            note: note.into(),
            timestamp: Utc::now(),
            shared: false,
        }
    }

    /// Mark this interaction as shared
    pub fn shared(mut self) -> Self {
        self.shared = true;
        self
    }

    /// Create an appreciation interaction
    pub fn appreciation(
        from: impl Into<String>,
        with: Vec<String>,
        note: impl Into<String>,
    ) -> Self {
        Self::new(InteractionKind::Appreciation, from, with, note)
    }

    /// Create a feedback interaction
    pub fn feedback(from: impl Into<String>, with: Vec<String>, note: impl Into<String>) -> Self {
        Self::new(InteractionKind::Feedback, from, with, note)
    }
}

/// Generate a simple unique ID
fn generate_id() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let duration = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default();
    format!("{:x}{:x}", duration.as_secs(), duration.subsec_nanos())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_interaction() {
        let interaction = Interaction::new(
            InteractionKind::Appreciation,
            "alice@example.com",
            vec!["bob@example.com".to_string()],
            "Great work on the PR!",
        );

        assert_eq!(interaction.kind, InteractionKind::Appreciation);
        assert_eq!(interaction.from, "alice@example.com");
        assert_eq!(interaction.with, vec!["bob@example.com"]);
        assert_eq!(interaction.note, "Great work on the PR!");
        assert!(!interaction.shared);
    }

    #[test]
    fn test_appreciation_helper() {
        let interaction = Interaction::appreciation(
            "alice@example.com",
            vec!["bob@example.com".to_string()],
            "Thanks!",
        );
        assert_eq!(interaction.kind, InteractionKind::Appreciation);
    }

    #[test]
    fn test_shared_interaction() {
        let interaction = Interaction::appreciation(
            "alice@example.com",
            vec!["bob@example.com".to_string()],
            "Thanks!",
        )
        .shared();
        assert!(interaction.shared);
    }

    #[test]
    fn test_interaction_kind_labels() {
        assert_eq!(InteractionKind::Appreciation.label(), "Appreciation");
        assert_eq!(InteractionKind::Feedback.label(), "Feedback");
        assert_eq!(InteractionKind::Apology.label(), "Apology");
        assert_eq!(InteractionKind::CheckIn.label(), "Check-in");
        assert_eq!(InteractionKind::Retrospective.label(), "Retrospective");
    }

    #[test]
    fn test_interaction_serialization() {
        let interaction = Interaction::appreciation(
            "alice@example.com",
            vec!["bob@example.com".to_string()],
            "Thanks!",
        );

        let yaml = serde_yaml::to_string(&interaction).unwrap();
        let parsed: Interaction = serde_yaml::from_str(&yaml).unwrap();
        assert_eq!(interaction.kind, parsed.kind);
        assert_eq!(interaction.from, parsed.from);
        assert_eq!(interaction.note, parsed.note);
    }
}
