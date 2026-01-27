//! OKR (Objectives and Key Results) model
//!
//! Based on the OKR framework, tied to manifesto principles.

use serde::{Deserialize, Serialize};

/// Visibility level for OKRs
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Default)]
#[serde(rename_all = "snake_case")]
pub enum OkrVisibility {
    /// Only visible to the owner
    #[default]
    Private,
    /// Visible to team members
    Shared,
}

/// A key result that measures progress toward an objective
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct KeyResult {
    /// Description of the key result
    pub description: String,

    /// Current progress (0.0 to 1.0)
    #[serde(default)]
    pub progress: f32,

    /// Optional notes on progress
    #[serde(default)]
    pub notes: Option<String>,
}

impl KeyResult {
    /// Create a new key result
    pub fn new(description: impl Into<String>) -> Self {
        Self {
            description: description.into(),
            progress: 0.0,
            notes: None,
        }
    }

    /// Update the progress (clamped to 0.0-1.0)
    pub fn set_progress(&mut self, progress: f32) {
        self.progress = progress.clamp(0.0, 1.0);
    }

    /// Add a note
    pub fn with_note(mut self, note: impl Into<String>) -> Self {
        self.notes = Some(note.into());
        self
    }
}

/// An objective with key results
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Objective {
    /// Unique identifier
    pub id: String,

    /// The objective title
    pub title: String,

    /// Detailed description
    #[serde(default)]
    pub description: Option<String>,

    /// Key results that measure progress
    #[serde(default)]
    pub key_results: Vec<KeyResult>,

    /// Visibility level
    #[serde(default)]
    pub visibility: OkrVisibility,

    /// Owner email (for personal OKRs)
    #[serde(default)]
    pub owner: Option<String>,

    /// Quarter (e.g., "2026-Q1")
    #[serde(default)]
    pub quarter: Option<String>,
}

impl Objective {
    /// Create a new objective
    pub fn new(title: impl Into<String>) -> Self {
        Self {
            id: generate_okr_id(),
            title: title.into(),
            description: None,
            key_results: Vec::new(),
            visibility: OkrVisibility::default(),
            owner: None,
            quarter: None,
        }
    }

    /// Set the description
    pub fn with_description(mut self, description: impl Into<String>) -> Self {
        self.description = Some(description.into());
        self
    }

    /// Add a key result
    pub fn add_key_result(&mut self, kr: KeyResult) {
        self.key_results.push(kr);
    }

    /// Set visibility
    pub fn with_visibility(mut self, visibility: OkrVisibility) -> Self {
        self.visibility = visibility;
        self
    }

    /// Set owner
    pub fn with_owner(mut self, owner: impl Into<String>) -> Self {
        self.owner = Some(owner.into());
        self
    }

    /// Set quarter
    pub fn with_quarter(mut self, quarter: impl Into<String>) -> Self {
        self.quarter = Some(quarter.into());
        self
    }

    /// Calculate overall progress based on key results
    pub fn overall_progress(&self) -> f32 {
        if self.key_results.is_empty() {
            return 0.0;
        }
        let sum: f32 = self.key_results.iter().map(|kr| kr.progress).sum();
        sum / self.key_results.len() as f32
    }
}

/// Generate a simple unique ID for OKRs
fn generate_okr_id() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let duration = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default();
    format!("okr-{:x}{:x}", duration.as_secs(), duration.subsec_nanos())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_key_result() {
        let kr = KeyResult::new("Complete 10 code reviews");
        assert_eq!(kr.description, "Complete 10 code reviews");
        assert_eq!(kr.progress, 0.0);
        assert!(kr.notes.is_none());
    }

    #[test]
    fn test_key_result_progress() {
        let mut kr = KeyResult::new("Test");
        kr.set_progress(0.5);
        assert_eq!(kr.progress, 0.5);

        // Test clamping
        kr.set_progress(1.5);
        assert_eq!(kr.progress, 1.0);

        kr.set_progress(-0.5);
        assert_eq!(kr.progress, 0.0);
    }

    #[test]
    fn test_new_objective() {
        let obj = Objective::new("Improve code quality");
        assert_eq!(obj.title, "Improve code quality");
        assert!(obj.key_results.is_empty());
        assert_eq!(obj.visibility, OkrVisibility::Private);
    }

    #[test]
    fn test_objective_with_key_results() {
        let mut obj = Objective::new("Improve code quality")
            .with_description("Focus on maintainability")
            .with_quarter("2026-Q1");

        let mut kr1 = KeyResult::new("Complete 10 code reviews");
        kr1.set_progress(0.8);

        let mut kr2 = KeyResult::new("Reduce bug count by 50%");
        kr2.set_progress(0.6);

        obj.add_key_result(kr1);
        obj.add_key_result(kr2);

        assert_eq!(obj.key_results.len(), 2);
        let progress = obj.overall_progress();
        assert!(
            (progress - 0.7).abs() < 0.0001,
            "Expected ~0.7, got {}",
            progress
        );
    }

    #[test]
    fn test_overall_progress_empty() {
        let obj = Objective::new("Test");
        assert_eq!(obj.overall_progress(), 0.0);
    }

    #[test]
    fn test_objective_serialization() {
        let mut obj = Objective::new("Improve code quality")
            .with_visibility(OkrVisibility::Shared)
            .with_owner("alice@example.com");

        obj.add_key_result(KeyResult::new("Complete reviews"));

        let yaml = serde_yaml::to_string(&obj).unwrap();
        let parsed: Objective = serde_yaml::from_str(&yaml).unwrap();
        assert_eq!(obj.title, parsed.title);
        assert_eq!(obj.visibility, parsed.visibility);
    }
}
