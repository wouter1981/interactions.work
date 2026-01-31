//! FFI API for interactions-core
//!
//! This module exposes the core library types and functions to Flutter
//! via flutter_rust_bridge.

use flutter_rust_bridge::frb;

// Re-export core types with FFI-friendly wrappers

/// Credentials for pincode-based authentication.
///
/// Used for authenticating team members via their pincode.
#[frb(dart_metadata=("freezed"))]
pub struct Credentials {
    /// Salt used for hashing (hex encoded)
    pub salt: String,
    /// Hashed pincode (hex encoded)
    pub pincode_hash: String,
}

impl Credentials {
    /// Create new credentials from a pincode.
    ///
    /// Generates a random salt and hashes the pincode with it.
    /// Returns an error if the pincode is less than 4 characters.
    #[frb(sync)]
    pub fn create(pincode: String) -> Result<Credentials, String> {
        let creds = interactions_core::Credentials::new(&pincode).map_err(|e| e.to_string())?;
        Ok(Credentials {
            salt: creds.salt,
            pincode_hash: creds.pincode_hash,
        })
    }

    /// Verify a pincode against these credentials.
    #[frb(sync)]
    pub fn verify(&self, pincode: String) -> bool {
        let core_creds = interactions_core::Credentials {
            salt: self.salt.clone(),
            pincode_hash: self.pincode_hash.clone(),
        };
        core_creds.verify(&pincode)
    }
}

/// Member credentials stored in .team/members/{email}/credentials.yaml
#[frb(dart_metadata=("freezed"))]
pub struct MemberCredentials {
    /// The member's email
    pub email: String,
    /// The member's credentials
    pub credentials: Credentials,
}

impl MemberCredentials {
    /// Create new member credentials.
    #[frb(sync)]
    pub fn create(email: String, pincode: String) -> Result<MemberCredentials, String> {
        let creds = Credentials::create(pincode)?;
        Ok(MemberCredentials {
            email,
            credentials: creds,
        })
    }

    /// Verify the pincode.
    #[frb(sync)]
    pub fn verify(&self, pincode: String) -> bool {
        self.credentials.verify(pincode)
    }
}

/// A team with its manifesto, vision, and members.
#[frb(dart_metadata=("freezed"))]
pub struct Team {
    /// Team identifier/name
    pub name: String,
    /// Behavior norms and cultural principles the team strives for
    pub manifesto: Option<String>,
    /// What the team aims to achieve
    pub vision: Option<String>,
    /// Email addresses of team leaders
    pub leaders: Vec<String>,
    /// Email addresses of team members
    pub members: Vec<String>,
}

impl Team {
    /// Create a new team with the given name.
    #[frb(sync)]
    pub fn create(name: String) -> Team {
        Team {
            name,
            manifesto: None,
            vision: None,
            leaders: Vec::new(),
            members: Vec::new(),
        }
    }

    /// Check if an email is a leader.
    #[frb(sync)]
    pub fn is_leader(&self, email: String) -> bool {
        self.leaders.iter().any(|e| e == &email)
    }

    /// Check if an email is a member (including leaders).
    #[frb(sync)]
    pub fn is_member(&self, email: String) -> bool {
        self.members.iter().any(|e| e == &email) || self.is_leader(email)
    }
}

/// Configuration for publishing markdown files.
#[frb(dart_metadata=("freezed"))]
pub struct PublishConfig {
    /// Path to publish manifesto
    pub manifesto: Option<String>,
    /// Path to publish vision
    pub vision: Option<String>,
    /// Path to publish OKRs
    pub okrs: Option<String>,
}

/// Configuration for webhook notifications.
#[frb(dart_metadata=("freezed"))]
pub struct WebhookConfig {
    /// Discord webhook URL
    pub discord: Option<String>,
    /// Slack webhook URL
    pub slack: Option<String>,
    /// Signal configuration
    pub signal: Option<String>,
}

/// Configuration for linting on PRs.
#[frb(dart_metadata=("freezed"))]
pub struct LintingConfig {
    /// Whether linting is enabled
    pub enabled: bool,
    /// Target branch for PRs
    pub target_branch: Option<String>,
}

/// Configuration for backups.
#[frb(dart_metadata=("freezed"))]
pub struct BackupConfig {
    /// Protected branch for backups
    pub protected_branch: Option<String>,
}

/// Team configuration stored in .team/config.yaml
#[frb(dart_metadata=("freezed"))]
pub struct TeamConfig {
    /// Publish paths for generated markdown files
    pub publish: Option<PublishConfig>,
    /// Webhook URLs for notifications
    pub webhooks: Option<WebhookConfig>,
    /// Linting configuration
    pub linting: Option<LintingConfig>,
    /// Backup configuration
    pub backup: Option<BackupConfig>,
}

impl TeamConfig {
    /// Create an empty configuration.
    #[frb(sync)]
    pub fn create() -> TeamConfig {
        TeamConfig {
            publish: None,
            webhooks: None,
            linting: None,
            backup: None,
        }
    }

    /// Create a default configuration with sensible defaults.
    #[frb(sync)]
    pub fn with_defaults() -> TeamConfig {
        TeamConfig {
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
}

/// A team member's profile.
#[frb(dart_metadata=("freezed"))]
pub struct Member {
    /// Member's email address (unique identifier)
    pub email: String,
    /// Display name
    pub name: Option<String>,
    /// Short bio or description
    pub bio: Option<String>,
    /// Timezone for pulse notifications
    pub timezone: Option<String>,
}

impl Member {
    /// Create a new member with the given email.
    #[frb(sync)]
    pub fn create(email: String) -> Member {
        Member {
            email,
            name: None,
            bio: None,
            timezone: None,
        }
    }

    /// Get the display name, falling back to email if not set.
    #[frb(sync)]
    pub fn display_name(&self) -> String {
        self.name.clone().unwrap_or_else(|| self.email.clone())
    }
}

/// The kind of interaction.
#[frb]
#[derive(Clone, Copy, PartialEq, Eq)]
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
    /// Get a human-readable label for this kind.
    #[frb(sync)]
    pub fn label(&self) -> String {
        match self {
            Self::Appreciation => "Appreciation".to_string(),
            Self::Feedback => "Feedback".to_string(),
            Self::Apology => "Apology".to_string(),
            Self::CheckIn => "Check-in".to_string(),
            Self::Retrospective => "Retrospective".to_string(),
        }
    }
}

/// A logged interaction between people.
#[frb(dart_metadata=("freezed"))]
pub struct Interaction {
    /// Unique identifier
    pub id: String,
    /// The kind of interaction
    pub kind: InteractionKind,
    /// Who logged this interaction
    pub from: String,
    /// Who the interaction was with
    pub with_members: Vec<String>,
    /// Brief description or note
    pub note: String,
    /// Timestamp as ISO 8601 string
    pub timestamp: String,
    /// Whether this is shared with the team or private
    pub shared: bool,
}

impl Interaction {
    /// Create a new interaction.
    #[frb(sync)]
    pub fn create(
        kind: InteractionKind,
        from: String,
        with_members: Vec<String>,
        note: String,
    ) -> Interaction {
        use std::time::{SystemTime, UNIX_EPOCH};
        let duration = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default();
        let id = format!("{:x}{:x}", duration.as_secs(), duration.subsec_nanos());
        let timestamp = chrono::Utc::now().to_rfc3339();

        Interaction {
            id,
            kind,
            from,
            with_members,
            note,
            timestamp,
            shared: false,
        }
    }

    /// Create an appreciation interaction.
    #[frb(sync)]
    pub fn appreciation(from: String, with_members: Vec<String>, note: String) -> Interaction {
        Self::create(InteractionKind::Appreciation, from, with_members, note)
    }

    /// Create a feedback interaction.
    #[frb(sync)]
    pub fn feedback(from: String, with_members: Vec<String>, note: String) -> Interaction {
        Self::create(InteractionKind::Feedback, from, with_members, note)
    }
}

/// Visibility level for OKRs.
#[frb]
#[derive(Clone, Copy, PartialEq, Eq, Default)]
pub enum OkrVisibility {
    /// Only visible to the owner
    #[default]
    Private,
    /// Visible to team members
    Shared,
}

/// A key result that measures progress toward an objective.
#[frb(dart_metadata=("freezed"))]
pub struct KeyResult {
    /// Description of the key result
    pub description: String,
    /// Current progress (0.0 to 1.0)
    pub progress: f32,
    /// Optional notes on progress
    pub notes: Option<String>,
}

impl KeyResult {
    /// Create a new key result.
    #[frb(sync)]
    pub fn create(description: String) -> KeyResult {
        KeyResult {
            description,
            progress: 0.0,
            notes: None,
        }
    }

    /// Clamp progress to valid range (0.0-1.0).
    #[frb(sync)]
    pub fn clamp_progress(progress: f32) -> f32 {
        progress.clamp(0.0, 1.0)
    }
}

/// An objective with key results.
#[frb(dart_metadata=("freezed"))]
pub struct Objective {
    /// Unique identifier
    pub id: String,
    /// The objective title
    pub title: String,
    /// Detailed description
    pub description: Option<String>,
    /// Key results that measure progress
    pub key_results: Vec<KeyResult>,
    /// Visibility level
    pub visibility: OkrVisibility,
    /// Owner email (for personal OKRs)
    pub owner: Option<String>,
    /// Quarter (e.g., "2026-Q1")
    pub quarter: Option<String>,
}

impl Objective {
    /// Create a new objective.
    #[frb(sync)]
    pub fn create(title: String) -> Objective {
        use std::time::{SystemTime, UNIX_EPOCH};
        let duration = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default();
        let id = format!("okr-{:x}{:x}", duration.as_secs(), duration.subsec_nanos());

        Objective {
            id,
            title,
            description: None,
            key_results: Vec::new(),
            visibility: OkrVisibility::default(),
            owner: None,
            quarter: None,
        }
    }

    /// Calculate overall progress based on key results.
    #[frb(sync)]
    pub fn overall_progress(&self) -> f32 {
        if self.key_results.is_empty() {
            return 0.0;
        }
        let sum: f32 = self.key_results.iter().map(|kr| kr.progress).sum();
        sum / self.key_results.len() as f32
    }
}

// ============================================================================
// YAML Serialization Functions
// ============================================================================

/// Serialize credentials to YAML string.
#[frb(sync)]
pub fn credentials_to_yaml(credentials: &Credentials) -> Result<String, String> {
    let core = interactions_core::Credentials {
        salt: credentials.salt.clone(),
        pincode_hash: credentials.pincode_hash.clone(),
    };
    serde_yaml::to_string(&core).map_err(|e| e.to_string())
}

/// Parse credentials from YAML string.
#[frb(sync)]
pub fn credentials_from_yaml(yaml: String) -> Result<Credentials, String> {
    let core: interactions_core::Credentials =
        serde_yaml::from_str(&yaml).map_err(|e| e.to_string())?;
    Ok(Credentials {
        salt: core.salt,
        pincode_hash: core.pincode_hash,
    })
}

/// Serialize member credentials to YAML string.
#[frb(sync)]
pub fn member_credentials_to_yaml(creds: &MemberCredentials) -> Result<String, String> {
    let core_creds = interactions_core::Credentials {
        salt: creds.credentials.salt.clone(),
        pincode_hash: creds.credentials.pincode_hash.clone(),
    };
    let core = interactions_core::MemberCredentials {
        email: creds.email.clone(),
        credentials: core_creds,
    };
    serde_yaml::to_string(&core).map_err(|e| e.to_string())
}

/// Parse member credentials from YAML string.
#[frb(sync)]
pub fn member_credentials_from_yaml(yaml: String) -> Result<MemberCredentials, String> {
    let core: interactions_core::MemberCredentials =
        serde_yaml::from_str(&yaml).map_err(|e| e.to_string())?;
    Ok(MemberCredentials {
        email: core.email,
        credentials: Credentials {
            salt: core.credentials.salt,
            pincode_hash: core.credentials.pincode_hash,
        },
    })
}

/// Serialize team to YAML string.
#[frb(sync)]
pub fn team_to_yaml(team: &Team) -> Result<String, String> {
    let core = interactions_core::Team {
        name: team.name.clone(),
        manifesto: team.manifesto.clone(),
        vision: team.vision.clone(),
        leaders: team.leaders.clone(),
        members: team.members.clone(),
    };
    serde_yaml::to_string(&core).map_err(|e| e.to_string())
}

/// Parse team from YAML string.
#[frb(sync)]
pub fn team_from_yaml(yaml: String) -> Result<Team, String> {
    let core: interactions_core::Team = serde_yaml::from_str(&yaml).map_err(|e| e.to_string())?;
    Ok(Team {
        name: core.name,
        manifesto: core.manifesto,
        vision: core.vision,
        leaders: core.leaders,
        members: core.members,
    })
}

/// Serialize team config to YAML string.
#[frb(sync)]
pub fn team_config_to_yaml(config: &TeamConfig) -> Result<String, String> {
    let core = interactions_core::TeamConfig {
        publish: config
            .publish
            .as_ref()
            .map(|p| interactions_core::PublishConfig {
                manifesto: p.manifesto.clone(),
                vision: p.vision.clone(),
                okrs: p.okrs.clone(),
            }),
        webhooks: config
            .webhooks
            .as_ref()
            .map(|w| interactions_core::WebhookConfig {
                discord: w.discord.clone(),
                slack: w.slack.clone(),
                signal: w.signal.clone(),
            }),
        linting: config
            .linting
            .as_ref()
            .map(|l| interactions_core::LintingConfig {
                enabled: l.enabled,
                target_branch: l.target_branch.clone(),
            }),
        backup: config
            .backup
            .as_ref()
            .map(|b| interactions_core::BackupConfig {
                protected_branch: b.protected_branch.clone(),
            }),
    };
    serde_yaml::to_string(&core).map_err(|e| e.to_string())
}

/// Parse team config from YAML string.
#[frb(sync)]
pub fn team_config_from_yaml(yaml: String) -> Result<TeamConfig, String> {
    let core: interactions_core::TeamConfig =
        serde_yaml::from_str(&yaml).map_err(|e| e.to_string())?;
    Ok(TeamConfig {
        publish: core.publish.map(|p| PublishConfig {
            manifesto: p.manifesto,
            vision: p.vision,
            okrs: p.okrs,
        }),
        webhooks: core.webhooks.map(|w| WebhookConfig {
            discord: w.discord,
            slack: w.slack,
            signal: w.signal,
        }),
        linting: core.linting.map(|l| LintingConfig {
            enabled: l.enabled,
            target_branch: l.target_branch,
        }),
        backup: core.backup.map(|b| BackupConfig {
            protected_branch: b.protected_branch,
        }),
    })
}

/// Serialize member to YAML string.
#[frb(sync)]
pub fn member_to_yaml(member: &Member) -> Result<String, String> {
    let core = interactions_core::Member {
        email: member.email.clone(),
        name: member.name.clone(),
        bio: member.bio.clone(),
        timezone: member.timezone.clone(),
    };
    serde_yaml::to_string(&core).map_err(|e| e.to_string())
}

/// Parse member from YAML string.
#[frb(sync)]
pub fn member_from_yaml(yaml: String) -> Result<Member, String> {
    let core: interactions_core::Member = serde_yaml::from_str(&yaml).map_err(|e| e.to_string())?;
    Ok(Member {
        email: core.email,
        name: core.name,
        bio: core.bio,
        timezone: core.timezone,
    })
}

/// Serialize interaction to YAML string.
#[frb(sync)]
pub fn interaction_to_yaml(interaction: &Interaction) -> Result<String, String> {
    let kind = match interaction.kind {
        InteractionKind::Appreciation => interactions_core::InteractionKind::Appreciation,
        InteractionKind::Feedback => interactions_core::InteractionKind::Feedback,
        InteractionKind::Apology => interactions_core::InteractionKind::Apology,
        InteractionKind::CheckIn => interactions_core::InteractionKind::CheckIn,
        InteractionKind::Retrospective => interactions_core::InteractionKind::Retrospective,
    };

    let timestamp = chrono::DateTime::parse_from_rfc3339(&interaction.timestamp)
        .map(|dt| dt.with_timezone(&chrono::Utc))
        .unwrap_or_else(|_| chrono::Utc::now());

    let core = interactions_core::Interaction {
        id: interaction.id.clone(),
        kind,
        from: interaction.from.clone(),
        with: interaction.with_members.clone(),
        note: interaction.note.clone(),
        timestamp,
        shared: interaction.shared,
    };
    serde_yaml::to_string(&core).map_err(|e| e.to_string())
}

/// Parse interaction from YAML string.
#[frb(sync)]
pub fn interaction_from_yaml(yaml: String) -> Result<Interaction, String> {
    let core: interactions_core::Interaction =
        serde_yaml::from_str(&yaml).map_err(|e| e.to_string())?;

    let kind = match core.kind {
        interactions_core::InteractionKind::Appreciation => InteractionKind::Appreciation,
        interactions_core::InteractionKind::Feedback => InteractionKind::Feedback,
        interactions_core::InteractionKind::Apology => InteractionKind::Apology,
        interactions_core::InteractionKind::CheckIn => InteractionKind::CheckIn,
        interactions_core::InteractionKind::Retrospective => InteractionKind::Retrospective,
    };

    Ok(Interaction {
        id: core.id,
        kind,
        from: core.from,
        with_members: core.with,
        note: core.note,
        timestamp: core.timestamp.to_rfc3339(),
        shared: core.shared,
    })
}

/// Serialize objective to YAML string.
#[frb(sync)]
pub fn objective_to_yaml(objective: &Objective) -> Result<String, String> {
    let visibility = match objective.visibility {
        OkrVisibility::Private => interactions_core::OkrVisibility::Private,
        OkrVisibility::Shared => interactions_core::OkrVisibility::Shared,
    };

    let key_results: Vec<interactions_core::KeyResult> = objective
        .key_results
        .iter()
        .map(|kr| interactions_core::KeyResult {
            description: kr.description.clone(),
            progress: kr.progress,
            notes: kr.notes.clone(),
        })
        .collect();

    let core = interactions_core::Objective {
        id: objective.id.clone(),
        title: objective.title.clone(),
        description: objective.description.clone(),
        key_results,
        visibility,
        owner: objective.owner.clone(),
        quarter: objective.quarter.clone(),
    };
    serde_yaml::to_string(&core).map_err(|e| e.to_string())
}

/// Parse objective from YAML string.
#[frb(sync)]
pub fn objective_from_yaml(yaml: String) -> Result<Objective, String> {
    let core: interactions_core::Objective =
        serde_yaml::from_str(&yaml).map_err(|e| e.to_string())?;

    let visibility = match core.visibility {
        interactions_core::OkrVisibility::Private => OkrVisibility::Private,
        interactions_core::OkrVisibility::Shared => OkrVisibility::Shared,
    };

    let key_results: Vec<KeyResult> = core
        .key_results
        .iter()
        .map(|kr| KeyResult {
            description: kr.description.clone(),
            progress: kr.progress,
            notes: kr.notes.clone(),
        })
        .collect();

    Ok(Objective {
        id: core.id,
        title: core.title,
        description: core.description,
        key_results,
        visibility,
        owner: core.owner,
        quarter: core.quarter,
    })
}
