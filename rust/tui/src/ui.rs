//! UI rendering with Ratatui

use crate::app::{App, Tab};
use ratatui::{
    prelude::*,
    widgets::{Block, Borders, List, ListItem, Paragraph, Tabs, Wrap},
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
         Run 'interactions init' to create a new team,\n\
         or navigate to a directory with a .team/ folder.\n\n\
         Use Tab to switch between sections.\n\
         Use ↑/↓ or j/k to navigate.\n\
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
        for leader in &team.leaders {
            items.push(ListItem::new(format!("★ {} (leader)", leader)));
        }
        for member in &team.members {
            items.push(ListItem::new(format!("  {}", member)));
        }
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
    let help_text = if let Some(msg) = &app.status_message {
        msg.clone()
    } else {
        "Tab: switch sections | ↑↓/jk: navigate | Enter: select | q: quit".to_string()
    };

    let footer = Paragraph::new(help_text)
        .block(Block::default().borders(Borders::ALL))
        .style(Style::default().fg(Color::Gray));

    frame.render_widget(footer, area);
}
