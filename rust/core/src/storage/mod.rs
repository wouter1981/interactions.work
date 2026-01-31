//! Storage module for reading/writing YAML files
//!
//! Handles the .team/ and .personal/ directory structures.

use crate::{auth::MemberCredentials, Error, Member, Result, Team, TeamConfig};
use std::path::{Path, PathBuf};

/// Paths for the team data storage
pub struct TeamStorage {
    root: PathBuf,
}

impl TeamStorage {
    /// Create a new TeamStorage with the given root directory
    pub fn new(root: impl AsRef<Path>) -> Self {
        Self {
            root: root.as_ref().to_path_buf(),
        }
    }

    /// Get the path to the .team directory
    pub fn team_dir(&self) -> PathBuf {
        self.root.join(".team")
    }

    /// Get the path to the .personal directory
    pub fn personal_dir(&self) -> PathBuf {
        self.root.join(".personal")
    }

    /// Check if the team storage is initialized
    pub fn is_initialized(&self) -> bool {
        self.team_dir().exists()
    }

    /// Initialize the team storage directories
    pub fn initialize(&self) -> Result<()> {
        let team_dir = self.team_dir();
        std::fs::create_dir_all(&team_dir)?;
        std::fs::create_dir_all(team_dir.join("members"))?;
        std::fs::create_dir_all(team_dir.join("team/okrs"))?;
        std::fs::create_dir_all(team_dir.join("team/interactions"))?;
        std::fs::create_dir_all(team_dir.join("team/retrospectives"))?;
        std::fs::create_dir_all(team_dir.join("drafts"))?;

        let personal_dir = self.personal_dir();
        std::fs::create_dir_all(&personal_dir)?;
        std::fs::create_dir_all(personal_dir.join("okrs"))?;
        std::fs::create_dir_all(personal_dir.join("journal"))?;
        std::fs::create_dir_all(personal_dir.join("drafts"))?;

        Ok(())
    }

    /// Load team configuration
    pub fn load_team(&self) -> Result<Option<Team>> {
        let config_path = self.team_dir().join("config.yaml");
        if !config_path.exists() {
            return Ok(None);
        }

        let content = std::fs::read_to_string(&config_path)?;
        let team: Team = serde_yaml::from_str(&content)?;
        Ok(Some(team))
    }

    /// Save team configuration
    pub fn save_team(&self, team: &Team) -> Result<()> {
        let config_path = self.team_dir().join("config.yaml");
        let content = serde_yaml::to_string(team)?;
        std::fs::write(config_path, content)?;
        Ok(())
    }

    /// Load manifesto content
    pub fn load_manifesto(&self) -> Result<Option<String>> {
        let path = self.team_dir().join("manifesto.yaml");
        if !path.exists() {
            return Ok(None);
        }
        let content = std::fs::read_to_string(&path)?;
        Ok(Some(content))
    }

    /// Save manifesto content
    pub fn save_manifesto(&self, content: &str) -> Result<()> {
        let path = self.team_dir().join("manifesto.yaml");
        std::fs::write(path, content)?;
        Ok(())
    }

    /// Load vision content
    pub fn load_vision(&self) -> Result<Option<String>> {
        let path = self.team_dir().join("vision.yaml");
        if !path.exists() {
            return Ok(None);
        }
        let content = std::fs::read_to_string(&path)?;
        Ok(Some(content))
    }

    /// Save vision content
    pub fn save_vision(&self, content: &str) -> Result<()> {
        let path = self.team_dir().join("vision.yaml");
        std::fs::write(path, content)?;
        Ok(())
    }

    /// Load team configuration
    pub fn load_config(&self) -> Result<Option<TeamConfig>> {
        let config_path = self.team_dir().join("config.yaml");
        if !config_path.exists() {
            return Ok(None);
        }

        let content = std::fs::read_to_string(&config_path)?;
        let config: TeamConfig = serde_yaml::from_str(&content)?;
        Ok(Some(config))
    }

    /// Save team configuration
    pub fn save_config(&self, config: &TeamConfig) -> Result<()> {
        let config_path = self.team_dir().join("config.yaml");
        let content = serde_yaml::to_string(config)?;
        std::fs::write(config_path, content)?;
        Ok(())
    }

    /// Get the path to a member's directory
    pub fn member_dir(&self, email: &str) -> PathBuf {
        self.team_dir().join("members").join(email)
    }

    /// Load a member's profile
    pub fn load_member(&self, email: &str) -> Result<Option<Member>> {
        let profile_path = self.member_dir(email).join("profile.yaml");
        if !profile_path.exists() {
            return Ok(None);
        }

        let content = std::fs::read_to_string(&profile_path)?;
        let member: Member = serde_yaml::from_str(&content)?;
        Ok(Some(member))
    }

    /// Save a member's profile
    pub fn save_member(&self, member: &Member) -> Result<()> {
        let member_dir = self.member_dir(&member.email);
        std::fs::create_dir_all(&member_dir)?;

        let profile_path = member_dir.join("profile.yaml");
        let content = serde_yaml::to_string(member)?;
        std::fs::write(profile_path, content)?;
        Ok(())
    }

    /// Load a member's credentials
    pub fn load_credentials(&self, email: &str) -> Result<Option<MemberCredentials>> {
        let creds_path = self.member_dir(email).join("credentials.yaml");
        if !creds_path.exists() {
            return Ok(None);
        }

        let content = std::fs::read_to_string(&creds_path)?;
        let creds: MemberCredentials = serde_yaml::from_str(&content)?;
        Ok(Some(creds))
    }

    /// Save a member's credentials
    pub fn save_credentials(&self, creds: &MemberCredentials) -> Result<()> {
        let member_dir = self.member_dir(&creds.email);
        std::fs::create_dir_all(&member_dir)?;

        let creds_path = member_dir.join("credentials.yaml");
        let content = serde_yaml::to_string(creds)?;
        std::fs::write(creds_path, content)?;
        Ok(())
    }

    /// Verify a member's pincode
    pub fn verify_pincode(&self, email: &str, pincode: &str) -> Result<bool> {
        let creds = self.load_credentials(email)?;
        match creds {
            Some(c) => Ok(c.verify(pincode)),
            None => Err(Error::CredentialsNotFound(email.to_string())),
        }
    }

    /// Initialize a new team with config, team info, and first member
    pub fn initialize_team(
        &self,
        team: &Team,
        config: &TeamConfig,
        leader: &Member,
        pincode: &str,
    ) -> Result<()> {
        // Initialize directory structure
        self.initialize()?;

        // Save config
        self.save_config(config)?;

        // Save team
        self.save_team(team)?;

        // Save leader profile
        self.save_member(leader)?;

        // Save leader credentials
        let creds = MemberCredentials::new(&leader.email, pincode)?;
        self.save_credentials(&creds)?;

        Ok(())
    }

    /// List all members
    pub fn list_members(&self) -> Result<Vec<String>> {
        let members_dir = self.team_dir().join("members");
        if !members_dir.exists() {
            return Ok(vec![]);
        }

        let mut members = vec![];
        for entry in std::fs::read_dir(members_dir)? {
            let entry = entry?;
            if entry.file_type()?.is_dir() {
                if let Some(name) = entry.file_name().to_str() {
                    members.push(name.to_string());
                }
            }
        }
        Ok(members)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn test_storage_initialization() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());

        assert!(!storage.is_initialized());
        storage.initialize().unwrap();
        assert!(storage.is_initialized());

        assert!(storage.team_dir().exists());
        assert!(storage.personal_dir().exists());
        assert!(storage.team_dir().join("members").exists());
        assert!(storage.team_dir().join("team/okrs").exists());
        assert!(storage.personal_dir().join("journal").exists());
    }

    #[test]
    fn test_team_save_load() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        let team = Team::new("Test Team")
            .with_manifesto("We collaborate")
            .with_vision("Build great things");

        storage.save_team(&team).unwrap();
        let loaded = storage.load_team().unwrap().unwrap();

        assert_eq!(team.name, loaded.name);
        assert_eq!(team.manifesto, loaded.manifesto);
        assert_eq!(team.vision, loaded.vision);
    }

    #[test]
    fn test_load_nonexistent_team() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        let loaded = storage.load_team().unwrap();
        assert!(loaded.is_none());
    }

    #[test]
    fn test_manifesto_save_load() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        let manifesto = "# Our Manifesto\n\nWe value collaboration.";
        storage.save_manifesto(manifesto).unwrap();

        let loaded = storage.load_manifesto().unwrap().unwrap();
        assert_eq!(manifesto, loaded);
    }

    #[test]
    fn test_config_save_load() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        let config = TeamConfig::with_defaults();
        storage.save_config(&config).unwrap();

        let loaded = storage.load_config().unwrap().unwrap();
        assert_eq!(config, loaded);
    }

    #[test]
    fn test_member_save_load() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        let member = Member::new("user@example.com")
            .with_name("Test User")
            .with_bio("A test user");

        storage.save_member(&member).unwrap();
        let loaded = storage.load_member("user@example.com").unwrap().unwrap();

        assert_eq!(member.email, loaded.email);
        assert_eq!(member.name, loaded.name);
        assert_eq!(member.bio, loaded.bio);
    }

    #[test]
    fn test_credentials_save_load_verify() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        let creds = MemberCredentials::new("user@example.com", "mypin123").unwrap();
        storage.save_credentials(&creds).unwrap();

        // Verify using storage method
        assert!(storage
            .verify_pincode("user@example.com", "mypin123")
            .unwrap());
        assert!(!storage
            .verify_pincode("user@example.com", "wrongpin")
            .unwrap());
    }

    #[test]
    fn test_credentials_not_found() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        let result = storage.verify_pincode("nonexistent@example.com", "anypin");
        assert!(result.is_err());
    }

    #[test]
    fn test_initialize_team() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());

        let team = Team::new("My Team")
            .with_manifesto("We collaborate")
            .add_leader("leader@example.com");

        let config = TeamConfig::with_defaults();

        let leader = Member::new("leader@example.com").with_name("Team Leader");

        storage
            .initialize_team(&team, &config, &leader, "leaderpin")
            .unwrap();

        // Verify everything was created
        assert!(storage.is_initialized());
        assert!(storage.load_team().unwrap().is_some());
        assert!(storage.load_config().unwrap().is_some());
        assert!(storage.load_member("leader@example.com").unwrap().is_some());
        assert!(storage
            .verify_pincode("leader@example.com", "leaderpin")
            .unwrap());
    }

    #[test]
    fn test_list_members() {
        let temp = TempDir::new().unwrap();
        let storage = TeamStorage::new(temp.path());
        storage.initialize().unwrap();

        // Add some members
        let member1 = Member::new("user1@example.com");
        let member2 = Member::new("user2@example.com");

        storage.save_member(&member1).unwrap();
        storage.save_member(&member2).unwrap();

        let members = storage.list_members().unwrap();
        assert_eq!(members.len(), 2);
        assert!(members.contains(&"user1@example.com".to_string()));
        assert!(members.contains(&"user2@example.com".to_string()));
    }
}
