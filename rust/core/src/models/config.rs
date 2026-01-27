//! Team configuration model
//!
//! Represents the .team/config.yaml file structure.

use serde::{Deserialize, Serialize};

/// Team configuration stored in .team/config.yaml
#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct TeamConfig {
    /// Publish paths for generated markdown files
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub publish: Option<PublishConfig>,

    /// Webhook URLs for notifications
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub webhooks: Option<WebhookConfig>,

    /// Linting configuration
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub linting: Option<LintingConfig>,

    /// Backup configuration
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub backup: Option<BackupConfig>,
}

impl TeamConfig {
    /// Create a new empty config
    pub fn new() -> Self {
        Self::default()
    }

    /// Create a default configuration with sensible defaults
    pub fn with_defaults() -> Self {
        Self {
            publish: Some(PublishConfig {
                manifesto: Some("/MANIFESTO.md".to_string()),
                vision: Some("/VISION.md".to_string()),
                okrs: Some("/okrs/".to_string()),
            }),
            webhooks: None,
            linting: Some(LintingConfig {
                enabled: true,
                target_branch: Some("interactions".to_string()),
            }),
            backup: Some(BackupConfig {
                protected_branch: Some("main".to_string()),
            }),
        }
    }

    /// Set publish configuration
    pub fn with_publish(mut self, publish: PublishConfig) -> Self {
        self.publish = Some(publish);
        self
    }

    /// Set linting configuration
    pub fn with_linting(mut self, linting: LintingConfig) -> Self {
        self.linting = Some(linting);
        self
    }

    /// Set backup configuration
    pub fn with_backup(mut self, backup: BackupConfig) -> Self {
        self.backup = Some(backup);
        self
    }
}

/// Configuration for publishing markdown files
#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct PublishConfig {
    /// Path to publish manifesto
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub manifesto: Option<String>,

    /// Path to publish vision
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub vision: Option<String>,

    /// Path to publish OKRs
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub okrs: Option<String>,
}

/// Configuration for webhook notifications
#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct WebhookConfig {
    /// Discord webhook URL
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub discord: Option<String>,

    /// Slack webhook URL
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub slack: Option<String>,

    /// Signal configuration
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub signal: Option<String>,
}

/// Configuration for linting on PRs
#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct LintingConfig {
    /// Whether linting is enabled
    #[serde(default)]
    pub enabled: bool,

    /// Target branch for PRs
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub target_branch: Option<String>,
}

/// Configuration for backups
#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct BackupConfig {
    /// Protected branch for backups
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub protected_branch: Option<String>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let config = TeamConfig::with_defaults();

        assert!(config.publish.is_some());
        assert!(config.linting.is_some());
        assert!(config.backup.is_some());

        let publish = config.publish.unwrap();
        assert_eq!(publish.manifesto, Some("/MANIFESTO.md".to_string()));
        assert_eq!(publish.vision, Some("/VISION.md".to_string()));
        assert_eq!(publish.okrs, Some("/okrs/".to_string()));

        let linting = config.linting.unwrap();
        assert!(linting.enabled);
        assert_eq!(linting.target_branch, Some("interactions".to_string()));

        let backup = config.backup.unwrap();
        assert_eq!(backup.protected_branch, Some("main".to_string()));
    }

    #[test]
    fn test_empty_config() {
        let config = TeamConfig::new();
        assert!(config.publish.is_none());
        assert!(config.webhooks.is_none());
        assert!(config.linting.is_none());
        assert!(config.backup.is_none());
    }

    #[test]
    fn test_config_serialization() {
        let config = TeamConfig::with_defaults();
        let yaml = serde_yaml::to_string(&config).unwrap();
        let parsed: TeamConfig = serde_yaml::from_str(&yaml).unwrap();
        assert_eq!(config, parsed);
    }

    #[test]
    fn test_config_builder() {
        let config = TeamConfig::new()
            .with_publish(PublishConfig {
                manifesto: Some("/docs/MANIFESTO.md".to_string()),
                vision: None,
                okrs: None,
            })
            .with_linting(LintingConfig {
                enabled: true,
                target_branch: Some("develop".to_string()),
            });

        assert!(config.publish.is_some());
        assert!(config.linting.is_some());
        assert!(config.backup.is_none());
    }

    #[test]
    fn test_webhook_config() {
        let webhooks = WebhookConfig {
            discord: Some("https://discord.com/webhook/123".to_string()),
            slack: None,
            signal: None,
        };

        let yaml = serde_yaml::to_string(&webhooks).unwrap();
        assert!(yaml.contains("discord:"));
        assert!(!yaml.contains("slack:"));
    }
}
