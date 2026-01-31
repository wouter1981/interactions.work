//! Application state management

use interactions_core::{Interaction, InteractionKind, Member, Team, TeamConfig, TeamStorage};

/// Sub-tabs for the Interactions tab
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum InteractionsSubTab {
    #[default]
    Kudos,
    Feedback,
}

impl InteractionsSubTab {
    pub fn title(&self) -> &'static str {
        match self {
            Self::Kudos => "Kudos",
            Self::Feedback => "Feedback",
        }
    }

    pub fn all() -> &'static [InteractionsSubTab] {
        &[InteractionsSubTab::Kudos, InteractionsSubTab::Feedback]
    }
}

/// View mode for the Interactions tab (sent vs received)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum InteractionsView {
    #[default]
    Sent,
    Received,
}
use std::path::{Path, PathBuf};
use std::{env, fs};

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
    ChangeDirectory,
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

/// Kudos wizard step
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum KudosStep {
    #[default]
    Recipient,
    Note,
    Share,
}

impl KudosStep {
    pub fn prompt(&self) -> &'static str {
        match self {
            KudosStep::Recipient => "Who are you giving kudos to? (email or name)",
            KudosStep::Note => "What would you like to say?",
            KudosStep::Share => "Share with the team? (y/n)",
        }
    }

    pub fn next(&self) -> Option<KudosStep> {
        match self {
            KudosStep::Recipient => Some(KudosStep::Note),
            KudosStep::Note => Some(KudosStep::Share),
            KudosStep::Share => None,
        }
    }
}

/// State for the kudos wizard
#[derive(Debug, Clone, Default)]
pub struct KudosState {
    pub step: KudosStep,
    pub recipient: String,
    pub note: String,
    pub shared: bool,
    pub input_buffer: String,
    pub error_message: Option<String>,
}

/// Feedback wizard step
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum FeedbackStep {
    #[default]
    Recipient,
    Note,
    Share,
}

impl FeedbackStep {
    pub fn prompt(&self) -> &'static str {
        match self {
            FeedbackStep::Recipient => "Who is this feedback for? (email or name)",
            FeedbackStep::Note => "What feedback would you like to share?",
            FeedbackStep::Share => "Share with the team? (y/n)",
        }
    }

    pub fn next(&self) -> Option<FeedbackStep> {
        match self {
            FeedbackStep::Recipient => Some(FeedbackStep::Note),
            FeedbackStep::Note => Some(FeedbackStep::Share),
            FeedbackStep::Share => None,
        }
    }
}

/// State for the feedback wizard
#[derive(Debug, Clone, Default)]
pub struct FeedbackState {
    pub step: FeedbackStep,
    pub recipient: String,
    pub note: String,
    pub shared: bool,
    pub input_buffer: String,
    pub error_message: Option<String>,
}

/// State for the directory navigation wizard
#[derive(Debug, Clone)]
pub struct NavigateDirState {
    /// Current directory being browsed
    pub current_dir: PathBuf,
    /// List of entries in the current directory
    pub entries: Vec<DirEntry>,
    /// Selected entry index
    pub selected_index: usize,
    /// Error message if any
    pub error_message: Option<String>,
    /// Input buffer for manual path entry
    pub input_buffer: String,
    /// Whether in manual path input mode
    pub input_mode: bool,
}

/// A directory entry for navigation
#[derive(Debug, Clone)]
pub struct DirEntry {
    pub name: String,
    pub is_dir: bool,
    pub path: PathBuf,
}

impl NavigateDirState {
    pub fn new(start_dir: &Path) -> Self {
        let mut state = Self {
            current_dir: start_dir.to_path_buf(),
            entries: Vec::new(),
            selected_index: 0,
            error_message: None,
            input_buffer: String::new(),
            input_mode: false,
        };
        state.refresh_entries();
        state
    }

    /// Refresh the directory entries list
    pub fn refresh_entries(&mut self) {
        self.entries.clear();
        self.selected_index = 0;

        // Add parent directory entry if not at root
        if let Some(parent) = self.current_dir.parent() {
            self.entries.push(DirEntry {
                name: "..".to_string(),
                is_dir: true,
                path: parent.to_path_buf(),
            });
        }

        // Read directory entries
        if let Ok(read_dir) = fs::read_dir(&self.current_dir) {
            let mut dirs: Vec<DirEntry> = Vec::new();

            for entry in read_dir.flatten() {
                let path = entry.path();
                let is_dir = path.is_dir();
                if let Some(name) = path.file_name() {
                    let name = name.to_string_lossy().to_string();
                    // Skip hidden files/directories (starting with .)
                    if !name.starts_with('.') && is_dir {
                        dirs.push(DirEntry { name, is_dir, path });
                    }
                }
            }

            // Sort directories alphabetically
            dirs.sort_by(|a, b| a.name.to_lowercase().cmp(&b.name.to_lowercase()));
            self.entries.extend(dirs);
        }
    }

    /// Navigate into the selected directory
    pub fn enter_selected(&mut self) -> bool {
        if let Some(entry) = self.entries.get(self.selected_index) {
            if entry.is_dir {
                self.current_dir = entry.path.clone();
                self.refresh_entries();
                self.error_message = None;
                return true;
            }
        }
        false
    }

    /// Move selection up
    pub fn select_previous(&mut self) {
        if !self.entries.is_empty() {
            self.selected_index = if self.selected_index == 0 {
                self.entries.len() - 1
            } else {
                self.selected_index - 1
            };
        }
    }

    /// Move selection down
    pub fn select_next(&mut self) {
        if !self.entries.is_empty() {
            self.selected_index = (self.selected_index + 1) % self.entries.len();
        }
    }
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

    /// Current working directory
    pub working_dir: PathBuf,

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

    /// Directory navigation wizard state (Some when navigating)
    pub navigate_dir_state: Option<NavigateDirState>,

    /// Kudos wizard state (Some when giving kudos)
    pub kudos_state: Option<KudosState>,

    /// Feedback wizard state (Some when giving feedback)
    pub feedback_state: Option<FeedbackState>,

    /// Current user email (for logging interactions)
    pub current_user: Option<String>,

    /// Current sub-tab in Interactions tab
    pub interactions_subtab: InteractionsSubTab,

    /// Current view in Interactions tab (sent vs received)
    pub interactions_view: InteractionsView,

    /// Loaded sent kudos
    pub sent_kudos: Vec<Interaction>,

    /// Loaded received kudos
    pub received_kudos: Vec<Interaction>,

    /// Loaded sent feedback
    pub sent_feedback: Vec<Interaction>,

    /// Loaded received feedback
    pub received_feedback: Vec<Interaction>,

    /// Selected interaction index in the current view
    pub interaction_index: usize,
}

impl App {
    /// Create a new application state
    pub fn new() -> Self {
        let cwd = env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
        Self::with_directory(cwd)
    }

    /// Create a new application state with a specific directory
    pub fn with_directory(dir: PathBuf) -> Self {
        let storage = TeamStorage::new(&dir);
        let team = storage.load_team().ok().flatten();
        let is_initialized = storage.is_initialized();

        // Get the current user from the first leader
        let current_user = team.as_ref().and_then(|t| t.leaders.first().cloned());

        // Load kudos and feedback
        let sent_kudos = storage.load_sent_kudos().unwrap_or_default();
        let received_kudos = current_user
            .as_ref()
            .and_then(|email| storage.load_received_kudos(email).ok())
            .unwrap_or_default();
        let sent_feedback = storage.load_sent_feedback().unwrap_or_default();
        let received_feedback = current_user
            .as_ref()
            .and_then(|email| storage.load_received_feedback(email).ok())
            .unwrap_or_default();

        let quick_actions = Self::build_quick_actions(is_initialized);

        Self {
            current_tab: Tab::default(),
            selected_index: 0,
            working_dir: dir,
            storage,
            team,
            quick_actions,
            status_message: None,
            init_state: None,
            add_member_state: None,
            navigate_dir_state: None,
            kudos_state: None,
            feedback_state: None,
            current_user,
            interactions_subtab: InteractionsSubTab::default(),
            interactions_view: InteractionsView::default(),
            sent_kudos,
            received_kudos,
            sent_feedback,
            received_feedback,
            interaction_index: 0,
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

        // Always show change directory option
        actions.push(QuickAction {
            label: "Open Folder",
            description: "Navigate to a different directory",
            kind: QuickActionKind::ChangeDirectory,
        });

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
                        QuickActionKind::ChangeDirectory => {
                            self.start_navigate_dir();
                        }
                        QuickActionKind::LogInteraction(kind) => match kind {
                            InteractionKind::Appreciation => {
                                self.start_kudos();
                            }
                            InteractionKind::Feedback => {
                                self.start_feedback();
                            }
                            _ => {
                                self.status_message =
                                    Some("This interaction type not yet implemented".to_string());
                            }
                        },
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

    /// Start the directory navigation wizard
    pub fn start_navigate_dir(&mut self) {
        self.navigate_dir_state = Some(NavigateDirState::new(&self.working_dir));
        self.status_message = None;
    }

    /// Cancel the directory navigation wizard
    pub fn cancel_navigate_dir(&mut self) {
        self.navigate_dir_state = None;
    }

    /// Check if currently in directory navigation mode
    pub fn is_navigate_dir_mode(&self) -> bool {
        self.navigate_dir_state.is_some()
    }

    /// Handle navigation input - move up
    pub fn navigate_dir_previous(&mut self) {
        if let Some(state) = &mut self.navigate_dir_state {
            state.select_previous();
        }
    }

    /// Handle navigation input - move down
    pub fn navigate_dir_next(&mut self) {
        if let Some(state) = &mut self.navigate_dir_state {
            state.select_next();
        }
    }

    /// Handle navigation input - enter directory or toggle input mode
    pub fn navigate_dir_enter(&mut self) {
        if let Some(state) = &mut self.navigate_dir_state {
            if state.input_mode {
                // Try to navigate to the entered path
                let path = PathBuf::from(&state.input_buffer);
                if path.is_dir() {
                    state.current_dir = path;
                    state.refresh_entries();
                    state.input_buffer.clear();
                    state.input_mode = false;
                    state.error_message = None;
                } else {
                    state.error_message = Some("Invalid directory path".to_string());
                }
            } else {
                state.enter_selected();
            }
        }
    }

    /// Toggle manual path input mode
    pub fn navigate_dir_toggle_input(&mut self) {
        if let Some(state) = &mut self.navigate_dir_state {
            state.input_mode = !state.input_mode;
            if state.input_mode {
                state.input_buffer = state.current_dir.to_string_lossy().to_string();
            }
            state.error_message = None;
        }
    }

    /// Handle character input during path entry
    pub fn navigate_dir_input_char(&mut self, c: char) {
        if let Some(state) = &mut self.navigate_dir_state {
            if state.input_mode {
                state.input_buffer.push(c);
                state.error_message = None;
            }
        }
    }

    /// Handle backspace during path entry
    pub fn navigate_dir_input_backspace(&mut self) {
        if let Some(state) = &mut self.navigate_dir_state {
            if state.input_mode {
                state.input_buffer.pop();
            }
        }
    }

    /// Select the current directory and reload the app
    pub fn navigate_dir_select(&mut self) {
        let Some(state) = self.navigate_dir_state.take() else {
            return;
        };

        let new_dir = state.current_dir.clone();

        // Update to the new directory
        self.working_dir = new_dir.clone();
        self.storage = TeamStorage::new(&new_dir);
        self.team = self.storage.load_team().ok().flatten();
        self.current_user = self.team.as_ref().and_then(|t| t.leaders.first().cloned());
        self.quick_actions = Self::build_quick_actions(self.storage.is_initialized());
        self.selected_index = 0;
        self.reload_interactions();
        self.status_message = Some(format!("Opened: {}", new_dir.display()));
    }

    /// Start the kudos wizard
    pub fn start_kudos(&mut self) {
        if !self.is_initialized() {
            self.status_message = Some("Initialize a team first to give kudos".to_string());
            return;
        }
        self.kudos_state = Some(KudosState::default());
        self.status_message = None;
    }

    /// Cancel the kudos wizard
    pub fn cancel_kudos(&mut self) {
        self.kudos_state = None;
        self.status_message = Some("Kudos cancelled".to_string());
    }

    /// Check if currently in kudos mode
    pub fn is_kudos_mode(&self) -> bool {
        self.kudos_state.is_some()
    }

    /// Handle character input during kudos mode
    pub fn kudos_input_char(&mut self, c: char) {
        if let Some(state) = &mut self.kudos_state {
            state.input_buffer.push(c);
            state.error_message = None;
        }
    }

    /// Handle backspace during kudos mode
    pub fn kudos_input_backspace(&mut self) {
        if let Some(state) = &mut self.kudos_state {
            state.input_buffer.pop();
        }
    }

    /// Submit the current kudos step
    pub fn kudos_submit(&mut self) {
        let should_complete = {
            let Some(state) = &mut self.kudos_state else {
                return;
            };

            let input = state.input_buffer.trim().to_string();

            // Validate and store based on current step
            match state.step {
                KudosStep::Recipient => {
                    if input.is_empty() {
                        state.error_message = Some("Please enter a recipient".to_string());
                        return;
                    }
                    state.recipient = input;
                }
                KudosStep::Note => {
                    if input.is_empty() {
                        state.error_message = Some("Please write a note".to_string());
                        return;
                    }
                    state.note = input;
                }
                KudosStep::Share => {
                    let lower = input.to_lowercase();
                    state.shared = lower == "y" || lower == "yes";
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
            self.complete_kudos();
        }
    }

    /// Complete the kudos process
    fn complete_kudos(&mut self) {
        let Some(state) = self.kudos_state.take() else {
            return;
        };

        let from = self
            .current_user
            .clone()
            .unwrap_or_else(|| "unknown".to_string());

        let mut interaction =
            Interaction::appreciation(&from, vec![state.recipient.clone()], &state.note);

        if state.shared {
            interaction = interaction.shared();
        }

        match self.storage.save_kudos(&interaction) {
            Ok(()) => {
                let share_text = if state.shared { " (shared)" } else { "" };
                self.status_message =
                    Some(format!("Kudos sent to {}!{}", state.recipient, share_text));
                self.reload_interactions();
            }
            Err(e) => {
                self.status_message = Some(format!("Error saving kudos: {}", e));
            }
        }
    }

    /// Start the feedback wizard
    pub fn start_feedback(&mut self) {
        if !self.is_initialized() {
            self.status_message = Some("Initialize a team first to share feedback".to_string());
            return;
        }
        self.feedback_state = Some(FeedbackState::default());
        self.status_message = None;
    }

    /// Cancel the feedback wizard
    pub fn cancel_feedback(&mut self) {
        self.feedback_state = None;
        self.status_message = Some("Feedback cancelled".to_string());
    }

    /// Check if currently in feedback mode
    pub fn is_feedback_mode(&self) -> bool {
        self.feedback_state.is_some()
    }

    /// Handle character input during feedback mode
    pub fn feedback_input_char(&mut self, c: char) {
        if let Some(state) = &mut self.feedback_state {
            state.input_buffer.push(c);
            state.error_message = None;
        }
    }

    /// Handle backspace during feedback mode
    pub fn feedback_input_backspace(&mut self) {
        if let Some(state) = &mut self.feedback_state {
            state.input_buffer.pop();
        }
    }

    /// Submit the current feedback step
    pub fn feedback_submit(&mut self) {
        let should_complete = {
            let Some(state) = &mut self.feedback_state else {
                return;
            };

            let input = state.input_buffer.trim().to_string();

            // Validate and store based on current step
            match state.step {
                FeedbackStep::Recipient => {
                    if input.is_empty() {
                        state.error_message = Some("Please enter a recipient".to_string());
                        return;
                    }
                    state.recipient = input;
                }
                FeedbackStep::Note => {
                    if input.is_empty() {
                        state.error_message = Some("Please write your feedback".to_string());
                        return;
                    }
                    state.note = input;
                }
                FeedbackStep::Share => {
                    let lower = input.to_lowercase();
                    state.shared = lower == "y" || lower == "yes";
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
            self.complete_feedback();
        }
    }

    /// Complete the feedback process
    fn complete_feedback(&mut self) {
        let Some(state) = self.feedback_state.take() else {
            return;
        };

        let from = self
            .current_user
            .clone()
            .unwrap_or_else(|| "unknown".to_string());

        let mut interaction =
            Interaction::feedback(&from, vec![state.recipient.clone()], &state.note);

        if state.shared {
            interaction = interaction.shared();
        }

        match self.storage.save_feedback(&interaction) {
            Ok(()) => {
                let share_text = if state.shared { " (shared)" } else { "" };
                self.status_message = Some(format!(
                    "Feedback sent to {}!{}",
                    state.recipient, share_text
                ));
                self.reload_interactions();
            }
            Err(e) => {
                self.status_message = Some(format!("Error saving feedback: {}", e));
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

    /// Reload all interactions from storage
    pub fn reload_interactions(&mut self) {
        self.sent_kudos = self.storage.load_sent_kudos().unwrap_or_default();
        self.received_kudos = self
            .current_user
            .as_ref()
            .and_then(|email| self.storage.load_received_kudos(email).ok())
            .unwrap_or_default();
        self.sent_feedback = self.storage.load_sent_feedback().unwrap_or_default();
        self.received_feedback = self
            .current_user
            .as_ref()
            .and_then(|email| self.storage.load_received_feedback(email).ok())
            .unwrap_or_default();
        self.interaction_index = 0;
    }

    /// Toggle between sent and received views
    pub fn toggle_interactions_view(&mut self) {
        self.interactions_view = match self.interactions_view {
            InteractionsView::Sent => InteractionsView::Received,
            InteractionsView::Received => InteractionsView::Sent,
        };
        self.interaction_index = 0;
    }

    /// Switch to next sub-tab
    pub fn next_subtab(&mut self) {
        self.interactions_subtab = match self.interactions_subtab {
            InteractionsSubTab::Kudos => InteractionsSubTab::Feedback,
            InteractionsSubTab::Feedback => InteractionsSubTab::Kudos,
        };
        self.interaction_index = 0;
    }

    /// Get the current interactions list based on sub-tab and view
    pub fn current_interactions(&self) -> &[Interaction] {
        match (self.interactions_subtab, self.interactions_view) {
            (InteractionsSubTab::Kudos, InteractionsView::Sent) => &self.sent_kudos,
            (InteractionsSubTab::Kudos, InteractionsView::Received) => &self.received_kudos,
            (InteractionsSubTab::Feedback, InteractionsView::Sent) => &self.sent_feedback,
            (InteractionsSubTab::Feedback, InteractionsView::Received) => &self.received_feedback,
        }
    }

    /// Move to next interaction in the list
    pub fn next_interaction(&mut self) {
        let len = self.current_interactions().len();
        if len > 0 {
            self.interaction_index = (self.interaction_index + 1) % len;
        }
    }

    /// Move to previous interaction in the list
    pub fn previous_interaction(&mut self) {
        let len = self.current_interactions().len();
        if len > 0 {
            self.interaction_index = if self.interaction_index == 0 {
                len - 1
            } else {
                self.interaction_index - 1
            };
        }
    }

    /// Get the working directory as a display string
    pub fn working_dir_display(&self) -> String {
        // Try to use home directory shorthand
        if let Some(home) = dirs::home_dir() {
            if let Ok(relative) = self.working_dir.strip_prefix(&home) {
                return format!("~/{}", relative.display());
            }
        }
        self.working_dir.display().to_string()
    }
}

impl Default for App {
    fn default() -> Self {
        Self::new()
    }
}
