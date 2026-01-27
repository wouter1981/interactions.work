//! Application state management

use interactions_core::{InteractionKind, Team, TeamStorage};
use std::path::PathBuf;

/// The main tabs in the TUI
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum Tab {
    #[default]
    Dashboard,
    Team,
    Interactions,
    Okrs,
    Settings,
}

impl Tab {
    pub fn title(&self) -> &'static str {
        match self {
            Tab::Dashboard => "Dashboard",
            Tab::Team => "Team",
            Tab::Interactions => "Interactions",
            Tab::Okrs => "OKRs",
            Tab::Settings => "Settings",
        }
    }

    pub fn all() -> &'static [Tab] {
        &[
            Tab::Dashboard,
            Tab::Team,
            Tab::Interactions,
            Tab::Okrs,
            Tab::Settings,
        ]
    }
}

/// Quick actions available from the dashboard
#[derive(Debug, Clone)]
pub struct QuickAction {
    pub label: &'static str,
    #[allow(dead_code)] // Will be used for tooltips in future iterations
    pub description: &'static str,
    pub kind: QuickActionKind,
}

#[derive(Debug, Clone)]
pub enum QuickActionKind {
    LogInteraction(InteractionKind),
    ViewTeam,
    ViewOkrs,
}

/// Application state
pub struct App {
    /// Current active tab
    pub current_tab: Tab,

    /// Selected item index in the current view
    pub selected_index: usize,

    /// Team storage handler
    pub storage: TeamStorage,

    /// Loaded team data (if available)
    pub team: Option<Team>,

    /// Quick actions for dashboard
    pub quick_actions: Vec<QuickAction>,

    /// Status message to display
    pub status_message: Option<String>,
}

impl App {
    /// Create a new application state
    pub fn new() -> Self {
        let cwd = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
        let storage = TeamStorage::new(&cwd);
        let team = storage.load_team().ok().flatten();

        let quick_actions = vec![
            QuickAction {
                label: "Give Kudos",
                description: "Appreciate someone's work",
                kind: QuickActionKind::LogInteraction(InteractionKind::Appreciation),
            },
            QuickAction {
                label: "Share Feedback",
                description: "Provide constructive feedback",
                kind: QuickActionKind::LogInteraction(InteractionKind::Feedback),
            },
            QuickAction {
                label: "Log Check-in",
                description: "Record a check-in conversation",
                kind: QuickActionKind::LogInteraction(InteractionKind::CheckIn),
            },
            QuickAction {
                label: "View Team",
                description: "See team members and manifesto",
                kind: QuickActionKind::ViewTeam,
            },
            QuickAction {
                label: "View OKRs",
                description: "Check objectives and progress",
                kind: QuickActionKind::ViewOkrs,
            },
        ];

        Self {
            current_tab: Tab::default(),
            selected_index: 0,
            storage,
            team,
            quick_actions,
            status_message: None,
        }
    }

    /// Move to the next tab
    pub fn next_tab(&mut self) {
        let tabs = Tab::all();
        let current_idx = tabs
            .iter()
            .position(|&t| t == self.current_tab)
            .unwrap_or(0);
        let next_idx = (current_idx + 1) % tabs.len();
        self.current_tab = tabs[next_idx];
        self.selected_index = 0;
    }

    /// Move to the previous tab
    pub fn previous_tab(&mut self) {
        let tabs = Tab::all();
        let current_idx = tabs
            .iter()
            .position(|&t| t == self.current_tab)
            .unwrap_or(0);
        let prev_idx = if current_idx == 0 {
            tabs.len() - 1
        } else {
            current_idx - 1
        };
        self.current_tab = tabs[prev_idx];
        self.selected_index = 0;
    }

    /// Move to the next item in the current view
    pub fn next_item(&mut self) {
        let max_index = self.max_index_for_tab();
        if max_index > 0 {
            self.selected_index = (self.selected_index + 1) % max_index;
        }
    }

    /// Move to the previous item in the current view
    pub fn previous_item(&mut self) {
        let max_index = self.max_index_for_tab();
        if max_index > 0 {
            self.selected_index = if self.selected_index == 0 {
                max_index - 1
            } else {
                self.selected_index - 1
            };
        }
    }

    /// Select the current item
    pub fn select_item(&mut self) {
        match self.current_tab {
            Tab::Dashboard => {
                if self.selected_index < self.quick_actions.len() {
                    let action = &self.quick_actions[self.selected_index];
                    match &action.kind {
                        QuickActionKind::LogInteraction(_kind) => {
                            self.status_message =
                                Some("Interaction logging not yet implemented".to_string());
                        }
                        QuickActionKind::ViewTeam => {
                            self.current_tab = Tab::Team;
                            self.selected_index = 0;
                        }
                        QuickActionKind::ViewOkrs => {
                            self.current_tab = Tab::Okrs;
                            self.selected_index = 0;
                        }
                    }
                }
            }
            _ => {
                // Other tabs don't have selection actions yet
            }
        }
    }

    /// Get the maximum selectable index for the current tab
    fn max_index_for_tab(&self) -> usize {
        match self.current_tab {
            Tab::Dashboard => self.quick_actions.len(),
            Tab::Team => self
                .team
                .as_ref()
                .map(|t| t.members.len() + t.leaders.len())
                .unwrap_or(0),
            _ => 0,
        }
    }

    /// Check if team storage is initialized
    pub fn is_initialized(&self) -> bool {
        self.storage.is_initialized()
    }

    /// Get team name or default
    pub fn team_name(&self) -> &str {
        self.team
            .as_ref()
            .map(|t| t.name.as_str())
            .unwrap_or("No Team")
    }
}

impl Default for App {
    fn default() -> Self {
        Self::new()
    }
}
