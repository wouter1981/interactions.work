//! Application state management

use interactions_core::{InteractionKind, Member, Team, TeamConfig, TeamStorage};
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
    InitTeam,
    LogInteraction(InteractionKind),
    ViewTeam,
    ViewOkrs,
}

/// Initialization wizard step
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum InitStep {
    #[default]
    TeamName,
    LeaderEmail,
    LeaderName,
    Pincode,
    ConfirmPincode,
}

/// Add member wizard step
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum AddMemberStep {
    #[default]
    Email,
    Name,
}

impl AddMemberStep {
    pub fn prompt(&self) -> &'static str {
        match self {
            AddMemberStep::Email => "Enter member's email:",
            AddMemberStep::Name => "Enter member's name (press Enter to skip):",
        }
    }

    pub fn next(&self) -> Option<AddMemberStep> {
        match self {
            AddMemberStep::Email => Some(AddMemberStep::Name),
            AddMemberStep::Name => None,
        }
    }
}

/// State for the add member wizard
#[derive(Debug, Clone, Default)]
pub struct AddMemberState {
    pub step: AddMemberStep,
    pub email: String,
    pub name: String,
    pub input_buffer: String,
    pub error_message: Option<String>,
}

impl InitStep {
    pub fn prompt(&self) -> &'static str {
        match self {
            InitStep::TeamName => "Enter your team name:",
            InitStep::LeaderEmail => "Enter your email (team leader):",
            InitStep::LeaderName => "Enter your name (press Enter to skip):",
            InitStep::Pincode => "Create a pincode (min 4 chars, hidden):",
            InitStep::ConfirmPincode => "Confirm your pincode:",
        }
    }

    pub fn next(&self) -> Option<InitStep> {
        match self {
            InitStep::TeamName => Some(InitStep::LeaderEmail),
            InitStep::LeaderEmail => Some(InitStep::LeaderName),
            InitStep::LeaderName => Some(InitStep::Pincode),
            InitStep::Pincode => Some(InitStep::ConfirmPincode),
            InitStep::ConfirmPincode => None,
        }
    }
}

/// State for the initialization wizard
#[derive(Debug, Clone, Default)]
pub struct InitState {
    pub step: InitStep,
    pub team_name: String,
    pub leader_email: String,
    pub leader_name: String,
    pub pincode: String,
    pub confirm_pincode: String,
    pub input_buffer: String,
    pub error_message: Option<String>,
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

    /// Initialization wizard state (Some when in init mode)
    pub init_state: Option<InitState>,

    /// Add member wizard state (Some when adding a member)
    pub add_member_state: Option<AddMemberState>,
}

impl App {
    /// Create a new application state
    pub fn new() -> Self {
        let cwd = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
        let storage = TeamStorage::new(&cwd);
        let team = storage.load_team().ok().flatten();
        let is_initialized = storage.is_initialized();

        let quick_actions = Self::build_quick_actions(is_initialized);

        Self {
            current_tab: Tab::default(),
            selected_index: 0,
            storage,
            team,
            quick_actions,
            status_message: None,
            init_state: None,
            add_member_state: None,
        }
    }

    /// Build quick actions based on initialization state
    fn build_quick_actions(is_initialized: bool) -> Vec<QuickAction> {
        let mut actions = Vec::new();

        if !is_initialized {
            actions.push(QuickAction {
                label: "Initialize Team",
                description: "Set up a new team in this directory",
                kind: QuickActionKind::InitTeam,
            });
        }

        actions.extend(vec![
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
        ]);

        actions
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
                        QuickActionKind::InitTeam => {
                            self.start_init();
                        }
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
            Tab::Team => {
                // Check if the user selected "Add Member" (last item in the list)
                if let Some(team) = &self.team {
                    let member_count = team.leaders.len() + team.members.len();
                    if self.selected_index == member_count {
                        // "Add Member" action selected
                        self.start_add_member();
                    }
                }
            }
            _ => {
                // Other tabs don't have selection actions yet
            }
        }
    }

    /// Start the initialization wizard
    pub fn start_init(&mut self) {
        self.init_state = Some(InitState::default());
        self.status_message = None;
    }

    /// Cancel the initialization wizard
    pub fn cancel_init(&mut self) {
        self.init_state = None;
        self.status_message = Some("Initialization cancelled".to_string());
    }

    /// Check if currently in init mode
    pub fn is_init_mode(&self) -> bool {
        self.init_state.is_some()
    }

    /// Handle character input during init mode
    pub fn init_input_char(&mut self, c: char) {
        if let Some(state) = &mut self.init_state {
            state.input_buffer.push(c);
            state.error_message = None;
        }
    }

    /// Handle backspace during init mode
    pub fn init_input_backspace(&mut self) {
        if let Some(state) = &mut self.init_state {
            state.input_buffer.pop();
        }
    }

    /// Submit the current init step
    pub fn init_submit(&mut self) {
        let should_complete = {
            let Some(state) = &mut self.init_state else {
                return;
            };

            let input = state.input_buffer.trim().to_string();

            // Validate and store based on current step
            match state.step {
                InitStep::TeamName => {
                    if input.is_empty() {
                        state.error_message = Some("Team name cannot be empty".to_string());
                        return;
                    }
                    state.team_name = input;
                }
                InitStep::LeaderEmail => {
                    if input.is_empty() || !input.contains('@') {
                        state.error_message =
                            Some("Please enter a valid email address".to_string());
                        return;
                    }
                    state.leader_email = input;
                }
                InitStep::LeaderName => {
                    state.leader_name = input; // Optional, can be empty
                }
                InitStep::Pincode => {
                    if input.len() < 4 {
                        state.error_message =
                            Some("Pincode must be at least 4 characters".to_string());
                        return;
                    }
                    state.pincode = input;
                }
                InitStep::ConfirmPincode => {
                    if input != state.pincode {
                        state.error_message = Some("Pincodes do not match".to_string());
                        state.input_buffer.clear();
                        return;
                    }
                    state.confirm_pincode = input;
                }
            }

            // Move to next step or complete
            if let Some(next_step) = state.step.next() {
                state.step = next_step;
                state.input_buffer.clear();
                false
            } else {
                true
            }
        };

        if should_complete {
            self.complete_init();
        }
    }

    /// Complete the initialization process
    fn complete_init(&mut self) {
        let Some(state) = self.init_state.take() else {
            return;
        };

        // Create the team
        let team = Team::new(&state.team_name).add_leader(&state.leader_email);
        let config = TeamConfig::with_defaults();
        let mut leader = Member::new(&state.leader_email);
        if !state.leader_name.is_empty() {
            leader = leader.with_name(&state.leader_name);
        }

        match self
            .storage
            .initialize_team(&team, &config, &leader, &state.pincode)
        {
            Ok(()) => {
                self.team = Some(team);
                self.quick_actions = Self::build_quick_actions(true);
                self.selected_index = 0;
                self.status_message = Some(format!(
                    "Team '{}' initialized successfully!",
                    state.team_name
                ));
            }
            Err(e) => {
                self.status_message = Some(format!("Error initializing team: {}", e));
            }
        }
    }

    /// Start the add member wizard
    pub fn start_add_member(&mut self) {
        self.add_member_state = Some(AddMemberState::default());
        self.status_message = None;
    }

    /// Cancel the add member wizard
    pub fn cancel_add_member(&mut self) {
        self.add_member_state = None;
        self.status_message = Some("Add member cancelled".to_string());
    }

    /// Check if currently in add member mode
    pub fn is_add_member_mode(&self) -> bool {
        self.add_member_state.is_some()
    }

    /// Handle character input during add member mode
    pub fn add_member_input_char(&mut self, c: char) {
        if let Some(state) = &mut self.add_member_state {
            state.input_buffer.push(c);
            state.error_message = None;
        }
    }

    /// Handle backspace during add member mode
    pub fn add_member_input_backspace(&mut self) {
        if let Some(state) = &mut self.add_member_state {
            state.input_buffer.pop();
        }
    }

    /// Submit the current add member step
    pub fn add_member_submit(&mut self) {
        let should_complete = {
            let Some(state) = &mut self.add_member_state else {
                return;
            };

            let input = state.input_buffer.trim().to_string();

            // Validate and store based on current step
            match state.step {
                AddMemberStep::Email => {
                    if input.is_empty() || !input.contains('@') {
                        state.error_message =
                            Some("Please enter a valid email address".to_string());
                        return;
                    }
                    // Check if member already exists
                    if let Some(team) = &self.team {
                        if team.is_member(&input) || team.is_leader(&input) {
                            state.error_message =
                                Some("This person is already a team member".to_string());
                            return;
                        }
                    }
                    state.email = input;
                }
                AddMemberStep::Name => {
                    state.name = input; // Optional, can be empty
                }
            }

            // Move to next step or complete
            if let Some(next_step) = state.step.next() {
                state.step = next_step;
                state.input_buffer.clear();
                false
            } else {
                true
            }
        };

        if should_complete {
            self.complete_add_member();
        }
    }

    /// Complete the add member process
    fn complete_add_member(&mut self) {
        let Some(state) = self.add_member_state.take() else {
            return;
        };

        // Create the member
        let mut member = Member::new(&state.email);
        if !state.name.is_empty() {
            member = member.with_name(&state.name);
        }

        // Save the member profile
        if let Err(e) = self.storage.save_member(&member) {
            self.status_message = Some(format!("Error saving member: {}", e));
            return;
        }

        // Update the team with the new member
        if let Some(team) = &mut self.team {
            team.push_member(&state.email);
            if let Err(e) = self.storage.save_team(team) {
                self.status_message = Some(format!("Error updating team: {}", e));
                return;
            }
        }

        let display_name = if state.name.is_empty() {
            state.email.clone()
        } else {
            state.name.clone()
        };

        self.status_message = Some(format!("Added {} to the team!", display_name));
    }

    /// Get the maximum selectable index for the current tab
    fn max_index_for_tab(&self) -> usize {
        match self.current_tab {
            Tab::Dashboard => self.quick_actions.len(),
            Tab::Team => self
                .team
                .as_ref()
                .map(|t| t.members.len() + t.leaders.len() + 1) // +1 for "Add Member" action
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
