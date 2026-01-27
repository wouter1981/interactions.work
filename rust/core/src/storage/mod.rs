//! Storage module for reading/writing YAML files
//!
//! Handles the .team/ and .personal/ directory structures.

use crate::{Result, Team};
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
}
