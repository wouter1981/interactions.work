//! Member model
//!
//! Represents a team member with their profile information.

use serde::{Deserialize, Serialize};

/// A team member's profile
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Member {
    /// Member's email address (unique identifier)
    pub email: String,

    /// Display name
    #[serde(default)]
    pub name: Option<String>,

    /// Short bio or description
    #[serde(default)]
    pub bio: Option<String>,

    /// Timezone for pulse notifications
    #[serde(default)]
    pub timezone: Option<String>,
}

impl Member {
    /// Create a new member with the given email
    pub fn new(email: impl Into<String>) -> Self {
        Self {
            email: email.into(),
            name: None,
            bio: None,
            timezone: None,
        }
    }

    /// Set the member's display name
    pub fn with_name(mut self, name: impl Into<String>) -> Self {
        self.name = Some(name.into());
        self
    }

    /// Set the member's bio
    pub fn with_bio(mut self, bio: impl Into<String>) -> Self {
        self.bio = Some(bio.into());
        self
    }

    /// Set the member's timezone
    pub fn with_timezone(mut self, timezone: impl Into<String>) -> Self {
        self.timezone = Some(timezone.into());
        self
    }

    /// Get the display name, falling back to email if not set
    pub fn display_name(&self) -> &str {
        self.name.as_deref().unwrap_or(&self.email)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_member() {
        let member = Member::new("user@example.com");
        assert_eq!(member.email, "user@example.com");
        assert!(member.name.is_none());
    }

    #[test]
    fn test_member_with_details() {
        let member = Member::new("user@example.com")
            .with_name("Alice")
            .with_bio("Software engineer")
            .with_timezone("Europe/Amsterdam");

        assert_eq!(member.name, Some("Alice".to_string()));
        assert_eq!(member.bio, Some("Software engineer".to_string()));
        assert_eq!(member.timezone, Some("Europe/Amsterdam".to_string()));
    }

    #[test]
    fn test_display_name() {
        let member_no_name = Member::new("user@example.com");
        assert_eq!(member_no_name.display_name(), "user@example.com");

        let member_with_name = Member::new("user@example.com").with_name("Alice");
        assert_eq!(member_with_name.display_name(), "Alice");
    }

    #[test]
    fn test_member_serialization() {
        let member = Member::new("user@example.com")
            .with_name("Alice")
            .with_bio("Engineer");

        let yaml = serde_yaml::to_string(&member).unwrap();
        let parsed: Member = serde_yaml::from_str(&yaml).unwrap();
        assert_eq!(member, parsed);
    }
}
