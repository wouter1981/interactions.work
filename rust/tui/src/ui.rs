//! UI rendering with Ratatui

use crate::app::{AddMemberStep, App, InitStep, Tab};
use ratatui::{
    prelude::*,
    widgets::{Block, Borders, Clear, List, ListItem, Paragraph, Tabs, Wrap},
};

/// Render the entire UI
pub fn render(frame: &mut Frame, app: &App) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3), // Header with tabs
            Constraint::Min(0),    // Main content
            Constraint::Length(3), // Footer with help
        ])
        .split(frame.area());

    render_header(frame, app, chunks[0]);
    render_content(frame, app, chunks[1]);
    render_footer(frame, app, chunks[2]);

    // Render init wizard overlay if in init mode
    if app.is_init_mode() {
        render_init_wizard(frame, app);
    }

    // Render add member wizard overlay if in add member mode
    if app.is_add_member_mode() {
        render_add_member_wizard(frame, app);
    }
}

/// Render the header with tabs
fn render_header(frame: &mut Frame, app: &App, area: Rect) {
    let titles: Vec<Line> = Tab::all()
        .iter()
        .map(|t| {
            let style = if *t == app.current_tab {
                Style::default().fg(Color::Yellow).bold()
            } else {
                Style::default().fg(Color::Gray)
            };
            Line::from(t.title()).style(style)
        })
        .collect();

    let tabs = Tabs::new(titles)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title(" interactions.work "),
        )
        .highlight_style(Style::default().fg(Color::Yellow))
        .select(
            Tab::all()
                .iter()
                .position(|&t| t == app.current_tab)
                .unwrap_or(0),
        );

    frame.render_widget(tabs, area);
}

/// Render the main content area
fn render_content(frame: &mut Frame, app: &App, area: Rect) {
    match app.current_tab {
        Tab::Dashboard => render_dashboard(frame, app, area),
        Tab::Team => render_team(frame, app, area),
        Tab::Interactions => render_interactions(frame, app, area),
        Tab::Okrs => render_okrs(frame, app, area),
        Tab::Settings => render_settings(frame, app, area),
    }
}

/// Render the dashboard tab
fn render_dashboard(frame: &mut Frame, app: &App, area: Rect) {
    let chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(50), Constraint::Percentage(50)])
        .split(area);

    // Quick actions on the left
    let items: Vec<ListItem> = app
        .quick_actions
        .iter()
        .enumerate()
        .map(|(i, action)| {
            let style = if i == app.selected_index {
                Style::default().fg(Color::Yellow).bold()
            } else {
                Style::default()
            };
            let prefix = if i == app.selected_index {
                "› "
            } else {
                "  "
            };
            ListItem::new(format!("{}{}", prefix, action.label)).style(style)
        })
        .collect();

    let actions_list = List::new(items).block(
        Block::default()
            .borders(Borders::ALL)
            .title(" Quick Actions "),
    );

    frame.render_widget(actions_list, chunks[0]);

    // Info panel on the right
    let info_text = if app.is_initialized() {
        format!(
            "Team: {}\n\nWelcome to interactions.work!\n\n\
             Use Tab to switch between sections.\n\
             Use ↑/↓ or j/k to navigate.\n\
             Press Enter to select.\n\
             Press q to quit.",
            app.team_name()
        )
    } else {
        "No team initialized.\n\n\
         Select 'Initialize Team' to set up a new team,\n\
         or navigate to a directory with a .team/ folder.\n\n\
         Use ↑/↓ or j/k to navigate.\n\
         Press Enter to select.\n\
         Press q to quit."
            .to_string()
    };

    let info = Paragraph::new(info_text)
        .block(Block::default().borders(Borders::ALL).title(" Welcome "))
        .wrap(Wrap { trim: true });

    frame.render_widget(info, chunks[1]);
}

/// Render the team tab
fn render_team(frame: &mut Frame, app: &App, area: Rect) {
    let chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(40), Constraint::Percentage(60)])
        .split(area);

    // Members list
    let members: Vec<ListItem> = if let Some(team) = &app.team {
        let mut items = Vec::new();
        let mut idx = 0;

        // Add leaders
        for leader in &team.leaders {
            let style = if idx == app.selected_index {
                Style::default().fg(Color::Yellow).bold()
            } else {
                Style::default()
            };
            let prefix = if idx == app.selected_index {
                "› "
            } else {
                "  "
            };
            items.push(ListItem::new(format!("{}★ {} (leader)", prefix, leader)).style(style));
            idx += 1;
        }

        // Add regular members
        for member in &team.members {
            let style = if idx == app.selected_index {
                Style::default().fg(Color::Yellow).bold()
            } else {
                Style::default()
            };
            let prefix = if idx == app.selected_index {
                "› "
            } else {
                "  "
            };
            items.push(ListItem::new(format!("{}  {}", prefix, member)).style(style));
            idx += 1;
        }

        // Add "Add Member" action
        let add_member_style = if idx == app.selected_index {
            Style::default().fg(Color::Green).bold()
        } else {
            Style::default().fg(Color::Green)
        };
        let add_prefix = if idx == app.selected_index {
            "› "
        } else {
            "  "
        };
        items.push(ListItem::new(format!("{}+ Add Member", add_prefix)).style(add_member_style));

        items
    } else {
        vec![ListItem::new("No team members")]
    };

    let members_list =
        List::new(members).block(Block::default().borders(Borders::ALL).title(" Members "));

    frame.render_widget(members_list, chunks[0]);

    // Team info
    let team_info = if let Some(team) = &app.team {
        let manifesto = team.manifesto.as_deref().unwrap_or("No manifesto defined");
        let vision = team.vision.as_deref().unwrap_or("No vision defined");
        format!("Manifesto:\n{}\n\nVision:\n{}", manifesto, vision)
    } else {
        "No team loaded.\n\nCreate a team to define your manifesto and vision.".to_string()
    };

    let info = Paragraph::new(team_info)
        .block(Block::default().borders(Borders::ALL).title(" Team Info "))
        .wrap(Wrap { trim: true });

    frame.render_widget(info, chunks[1]);
}

/// Render the interactions tab
fn render_interactions(frame: &mut Frame, _app: &App, area: Rect) {
    let text = "No interactions logged yet.\n\n\
                Use the dashboard to log your first interaction:\n\
                • Give kudos to appreciate someone's work\n\
                • Share constructive feedback\n\
                • Record check-in conversations\n\n\
                Interactions help build stronger relationships\n\
                and track meaningful moments with your team.";

    let paragraph = Paragraph::new(text)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title(" Interactions "),
        )
        .wrap(Wrap { trim: true });

    frame.render_widget(paragraph, area);
}

/// Render the OKRs tab
fn render_okrs(frame: &mut Frame, _app: &App, area: Rect) {
    let text = "No OKRs defined yet.\n\n\
                Objectives and Key Results help you:\n\
                • Set meaningful personal and team goals\n\
                • Track progress through self-reflection\n\
                • Connect objectives to your team's manifesto\n\n\
                OKRs can be private (only you see them) or\n\
                shared with your team for accountability.";

    let paragraph = Paragraph::new(text)
        .block(Block::default().borders(Borders::ALL).title(" OKRs "))
        .wrap(Wrap { trim: true });

    frame.render_widget(paragraph, area);
}

/// Render the settings tab
fn render_settings(frame: &mut Frame, app: &App, area: Rect) {
    let initialized_status = if app.is_initialized() { "Yes" } else { "No" };

    let text = format!(
        "Team initialized: {}\n\n\
         Configuration:\n\
         • Storage: .team/ and .personal/ directories\n\
         • Format: YAML files\n\
         • Backend: Git-compatible\n\n\
         Paths:\n\
         • Team data: .team/\n\
         • Personal data: .personal/ (gitignored)\n\
         • Published: Configured in .team/config.yaml",
        initialized_status
    );

    let paragraph = Paragraph::new(text)
        .block(Block::default().borders(Borders::ALL).title(" Settings "))
        .wrap(Wrap { trim: true });

    frame.render_widget(paragraph, area);
}

/// Render the footer with help text
fn render_footer(frame: &mut Frame, app: &App, area: Rect) {
    let help_text = if app.is_init_mode() || app.is_add_member_mode() {
        "Enter: submit | Esc: cancel".to_string()
    } else if let Some(msg) = &app.status_message {
        msg.clone()
    } else if app.current_tab == Tab::Team && app.team.is_some() {
        "Tab: switch | ↑↓/jk: navigate | Enter: select | a: add member | q: quit".to_string()
    } else {
        "Tab: switch sections | ↑↓/jk: navigate | Enter: select | q: quit".to_string()
    };

    let footer = Paragraph::new(help_text)
        .block(Block::default().borders(Borders::ALL))
        .style(Style::default().fg(Color::Gray));

    frame.render_widget(footer, area);
}

/// Render the initialization wizard as a modal overlay
fn render_init_wizard(frame: &mut Frame, app: &App) {
    let Some(state) = &app.init_state else {
        return;
    };

    // Calculate centered popup area
    let area = frame.area();
    let popup_width = 60.min(area.width.saturating_sub(4));
    let popup_height = 12.min(area.height.saturating_sub(4));
    let popup_x = (area.width.saturating_sub(popup_width)) / 2;
    let popup_y = (area.height.saturating_sub(popup_height)) / 2;
    let popup_area = Rect::new(popup_x, popup_y, popup_width, popup_height);

    // Clear the area behind the popup
    frame.render_widget(Clear, popup_area);

    // Render the popup block
    let block = Block::default()
        .borders(Borders::ALL)
        .title(" Initialize Team ")
        .title_style(Style::default().fg(Color::Yellow).bold())
        .border_style(Style::default().fg(Color::Yellow));

    let inner_area = block.inner(popup_area);
    frame.render_widget(block, popup_area);

    // Layout inside the popup
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(2), // Progress indicator
            Constraint::Length(2), // Prompt
            Constraint::Length(3), // Input field
            Constraint::Min(0),    // Error or info
        ])
        .split(inner_area);

    // Progress indicator
    let steps = ["Name", "Email", "Your Name", "Pincode", "Confirm"];
    let current_step_idx = match state.step {
        InitStep::TeamName => 0,
        InitStep::LeaderEmail => 1,
        InitStep::LeaderName => 2,
        InitStep::Pincode => 3,
        InitStep::ConfirmPincode => 4,
    };
    let progress: String = steps
        .iter()
        .enumerate()
        .map(|(i, s)| {
            if i == current_step_idx {
                format!("[{}]", s)
            } else if i < current_step_idx {
                format!("✓{}", s)
            } else {
                format!(" {} ", s)
            }
        })
        .collect::<Vec<_>>()
        .join(" → ");

    let progress_widget = Paragraph::new(progress)
        .style(Style::default().fg(Color::Cyan))
        .alignment(Alignment::Center);
    frame.render_widget(progress_widget, chunks[0]);

    // Prompt
    let prompt = Paragraph::new(state.step.prompt())
        .style(Style::default().fg(Color::White))
        .alignment(Alignment::Left);
    frame.render_widget(prompt, chunks[1]);

    // Input field - show asterisks for pincode fields
    let display_text = if matches!(state.step, InitStep::Pincode | InitStep::ConfirmPincode) {
        "*".repeat(state.input_buffer.len())
    } else {
        state.input_buffer.clone()
    };

    let input_block = Block::default()
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::White));

    let input = Paragraph::new(format!("{}█", display_text))
        .block(input_block)
        .style(Style::default().fg(Color::Yellow));
    frame.render_widget(input, chunks[2]);

    // Error message or info
    if let Some(error) = &state.error_message {
        let error_widget = Paragraph::new(error.as_str())
            .style(Style::default().fg(Color::Red))
            .alignment(Alignment::Left);
        frame.render_widget(error_widget, chunks[3]);
    } else {
        let info = match state.step {
            InitStep::Pincode => "Your pincode encrypts your private data (min 4 chars)",
            InitStep::LeaderName => "Press Enter to skip",
            _ => "",
        };
        let info_widget = Paragraph::new(info)
            .style(Style::default().fg(Color::DarkGray))
            .alignment(Alignment::Left);
        frame.render_widget(info_widget, chunks[3]);
    }
}

/// Render the add member wizard as a modal overlay
fn render_add_member_wizard(frame: &mut Frame, app: &App) {
    let Some(state) = &app.add_member_state else {
        return;
    };

    // Calculate centered popup area
    let area = frame.area();
    let popup_width = 50.min(area.width.saturating_sub(4));
    let popup_height = 10.min(area.height.saturating_sub(4));
    let popup_x = (area.width.saturating_sub(popup_width)) / 2;
    let popup_y = (area.height.saturating_sub(popup_height)) / 2;
    let popup_area = Rect::new(popup_x, popup_y, popup_width, popup_height);

    // Clear the area behind the popup
    frame.render_widget(Clear, popup_area);

    // Render the popup block
    let block = Block::default()
        .borders(Borders::ALL)
        .title(" Add Team Member ")
        .title_style(Style::default().fg(Color::Green).bold())
        .border_style(Style::default().fg(Color::Green));

    let inner_area = block.inner(popup_area);
    frame.render_widget(block, popup_area);

    // Layout inside the popup
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(2), // Progress indicator
            Constraint::Length(2), // Prompt
            Constraint::Length(3), // Input field
            Constraint::Min(0),    // Error or info
        ])
        .split(inner_area);

    // Progress indicator
    let steps = ["Email", "Name"];
    let current_step_idx = match state.step {
        AddMemberStep::Email => 0,
        AddMemberStep::Name => 1,
    };
    let progress: String = steps
        .iter()
        .enumerate()
        .map(|(i, s)| {
            if i == current_step_idx {
                format!("[{}]", s)
            } else if i < current_step_idx {
                format!("✓{}", s)
            } else {
                format!(" {} ", s)
            }
        })
        .collect::<Vec<_>>()
        .join(" → ");

    let progress_widget = Paragraph::new(progress)
        .style(Style::default().fg(Color::Cyan))
        .alignment(Alignment::Center);
    frame.render_widget(progress_widget, chunks[0]);

    // Prompt
    let prompt = Paragraph::new(state.step.prompt())
        .style(Style::default().fg(Color::White))
        .alignment(Alignment::Left);
    frame.render_widget(prompt, chunks[1]);

    // Input field
    let input_block = Block::default()
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::White));

    let input = Paragraph::new(format!("{}█", state.input_buffer))
        .block(input_block)
        .style(Style::default().fg(Color::Yellow));
    frame.render_widget(input, chunks[2]);

    // Error message or info
    if let Some(error) = &state.error_message {
        let error_widget = Paragraph::new(error.as_str())
            .style(Style::default().fg(Color::Red))
            .alignment(Alignment::Left);
        frame.render_widget(error_widget, chunks[3]);
    } else {
        let info = match state.step {
            AddMemberStep::Name => "Press Enter to skip",
            _ => "",
        };
        let info_widget = Paragraph::new(info)
            .style(Style::default().fg(Color::DarkGray))
            .alignment(Alignment::Left);
        frame.render_widget(info_widget, chunks[3]);
    }
}
