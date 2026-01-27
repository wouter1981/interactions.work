//! Team model
//!
//! A team is flexible and user-defined - it can be a sports team,
//! a multi-organization collaboration, or an open source project.

use serde::{Deserialize, Serialize};

/// A team with its manifesto, vision, and members
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Team {
    /// Team identifier/name
    pub name: String,

    /// Behavior norms and cultural principles the team strives for
    #[serde(default)]
    pub manifesto: Option<String>,

    /// What the team aims to achieve
    #[serde(default)]
    pub vision: Option<String>,

    /// Email addresses of team leaders who set purpose and maintain manifesto
    #[serde(default)]
    pub leaders: Vec<String>,

    /// Email addresses of team members who commit to following manifesto principles
    #[serde(default)]
    pub members: Vec<String>,
}

impl Team {
    /// Create a new team with the given name
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            manifesto: None,
            vision: None,
            leaders: Vec::new(),
            members: Vec::new(),
        }
    }

    /// Set the team manifesto
    pub fn with_manifesto(mut self, manifesto: impl Into<String>) -> Self {
        self.manifesto = Some(manifesto.into());
        self
    }

    /// Set the team vision
    pub fn with_vision(mut self, vision: impl Into<String>) -> Self {
        self.vision = Some(vision.into());
        self
    }

    /// Add a leader to the team
    pub fn add_leader(&mut self, email: impl Into<String>) {
        self.leaders.push(email.into());
    }

    /// Add a member to the team
    pub fn add_member(&mut self, email: impl Into<String>) {
        self.members.push(email.into());
    }

    /// Check if an email is a leader
    pub fn is_leader(&self, email: &str) -> bool {
        self.leaders.iter().any(|e| e == email)
    }

    /// Check if an email is a member (including leaders)
    pub fn is_member(&self, email: &str) -> bool {
        self.members.iter().any(|e| e == email) || self.is_leader(email)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_team() {
        let team = Team::new("Engineering");
        assert_eq!(team.name, "Engineering");
        assert!(team.manifesto.is_none());
        assert!(team.vision.is_none());
        assert!(team.leaders.is_empty());
        assert!(team.members.is_empty());
    }

    #[test]
    fn test_team_with_manifesto_and_vision() {
        let team = Team::new("Engineering")
            .with_manifesto("We value collaboration")
            .with_vision("Build great software");

        assert_eq!(team.manifesto, Some("We value collaboration".to_string()));
        assert_eq!(team.vision, Some("Build great software".to_string()));
    }

    #[test]
    fn test_team_membership() {
        let mut team = Team::new("Engineering");
        team.add_leader("leader@example.com");
        team.add_member("member@example.com");

        assert!(team.is_leader("leader@example.com"));
        assert!(!team.is_leader("member@example.com"));
        assert!(team.is_member("leader@example.com")); // Leaders are also members
        assert!(team.is_member("member@example.com"));
        assert!(!team.is_member("stranger@example.com"));
    }

    #[test]
    fn test_team_serialization() {
        let team = Team::new("Engineering")
            .with_manifesto("We value collaboration")
            .with_vision("Build great software");

        let yaml = serde_yaml::to_string(&team).unwrap();
        let parsed: Team = serde_yaml::from_str(&yaml).unwrap();
        assert_eq!(team, parsed);
    }
}
