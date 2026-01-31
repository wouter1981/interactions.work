//! interactions TUI - Terminal User Interface for interactions.work

mod app;
mod ui;

use app::App;
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use interactions_core::{Member, Team, TeamConfig, TeamStorage};
use ratatui::prelude::*;
use std::{env, io, io::Write, process};

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();

    // Handle CLI commands (headless mode)
    if args.len() > 1 {
        return run_command(&args[1..]);
    }

    // Run interactive TUI
    run_tui()
}

/// Run a CLI command in headless mode
fn run_command(args: &[String]) -> io::Result<()> {
    match args[0].as_str() {
        "init" => run_init(),
        "publish" => {
            println!("Publishing content from .team/ sources...");
            // TODO: Implement publish command
            println!("Publish command not yet implemented");
            Ok(())
        }
        "lint" => {
            println!("Linting .team/ structure...");
            // TODO: Implement lint command
            println!("Lint command not yet implemented");
            Ok(())
        }
        "pulse" => {
            println!("Sending pulse reminders...");
            // TODO: Implement pulse command
            println!("Pulse command not yet implemented");
            Ok(())
        }
        "backup" => {
            println!("Backing up to protected branch...");
            // TODO: Implement backup command
            println!("Backup command not yet implemented");
            Ok(())
        }
        "restore" => {
            if args.len() < 2 {
                eprintln!("Usage: interactions restore <commit>");
                process::exit(1);
            }
            println!("Restoring from commit {}...", args[1]);
            // TODO: Implement restore command
            println!("Restore command not yet implemented");
            Ok(())
        }
        "help" | "--help" | "-h" => {
            print_help();
            Ok(())
        }
        "version" | "--version" | "-V" => {
            println!("interactions {}", env!("CARGO_PKG_VERSION"));
            Ok(())
        }
        cmd => {
            eprintln!("Unknown command: {}", cmd);
            eprintln!("Run 'interactions help' for usage information");
            process::exit(1);
        }
    }
}

fn print_help() {
    println!(
        r#"interactions - Personal and team development goals

USAGE:
    interactions              Launch interactive TUI
    interactions <command>    Run a command in headless mode

COMMANDS:
    init        Initialize a new team in the current directory
    publish     Generate markdown files from .team/ sources
    lint        Validate .team/ structure (for PR checks)
    pulse       Send reminders via configured webhooks
    backup      Backup to protected branch (maintainers)
    restore     Restore from git history
    help        Print this help message
    version     Print version information

For more information, visit: https://github.com/wouter1981/interactions.work"#
    );
}

/// Prompt for user input with a message
fn prompt(message: &str) -> io::Result<String> {
    print!("{}", message);
    io::stdout().flush()?;
    let mut input = String::new();
    io::stdin().read_line(&mut input)?;
    Ok(input.trim().to_string())
}

/// Prompt for password input (hidden)
fn prompt_password(message: &str) -> io::Result<String> {
    print!("{}", message);
    io::stdout().flush()?;

    // Disable echo for password input
    let input = rpassword::read_password().unwrap_or_else(|_| {
        // Fallback to regular input if rpassword fails
        let mut input = String::new();
        io::stdin().read_line(&mut input).ok();
        input.trim().to_string()
    });

    Ok(input)
}

/// Run the init command to create a new team
fn run_init() -> io::Result<()> {
    let storage = TeamStorage::new(".");

    // Check if already initialized
    if storage.is_initialized() {
        println!("A team is already initialized in this directory.");
        println!("The .team/ folder already exists.");
        return Ok(());
    }

    println!("Welcome to interactions.work!");
    println!("Let's set up your team.\n");

    // Get team name
    let team_name = prompt("Team name: ")?;
    if team_name.is_empty() {
        eprintln!("Error: Team name cannot be empty");
        process::exit(1);
    }

    // Get leader email
    let leader_email = prompt("Your email (team leader): ")?;
    if leader_email.is_empty() || !leader_email.contains('@') {
        eprintln!("Error: Please provide a valid email address");
        process::exit(1);
    }

    // Get leader name (optional)
    let leader_name = prompt("Your name (optional): ")?;

    // Get pincode
    println!("\nYour pincode is used to encrypt your private data.");
    println!("It must be at least 4 characters.");
    let pincode = prompt_password("Pincode: ")?;
    if pincode.len() < 4 {
        eprintln!("Error: Pincode must be at least 4 characters");
        process::exit(1);
    }

    let pincode_confirm = prompt_password("Confirm pincode: ")?;
    if pincode != pincode_confirm {
        eprintln!("Error: Pincodes do not match");
        process::exit(1);
    }

    // Create the team
    let team = Team::new(&team_name).add_leader(&leader_email);
    let config = TeamConfig::with_defaults();
    let mut leader = Member::new(&leader_email);
    if !leader_name.is_empty() {
        leader = leader.with_name(&leader_name);
    }

    match storage.initialize_team(&team, &config, &leader, &pincode) {
        Ok(()) => {
            println!("\nTeam '{}' initialized successfully!", team_name);
            println!("\nCreated:");
            println!("  .team/     - Team data (commit to git)");
            println!("  .personal/ - Your private data (gitignored)");
            println!("\nRun 'interactions' to launch the TUI.");
        }
        Err(e) => {
            eprintln!("Error initializing team: {}", e);
            process::exit(1);
        }
    }

    Ok(())
}

/// Run the interactive TUI
fn run_tui() -> io::Result<()> {
    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create app and run
    let mut app = App::new();
    let result = run_app(&mut terminal, &mut app);

    // Restore terminal
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    result
}

/// Main application loop
fn run_app<B: Backend>(terminal: &mut Terminal<B>, app: &mut App) -> io::Result<()> {
    loop {
        terminal.draw(|f| ui::render(f, app))?;

        if let Event::Key(key) = event::read()? {
            if key.kind == KeyEventKind::Press {
                // Handle init mode separately
                if app.is_init_mode() {
                    match key.code {
                        KeyCode::Esc => app.cancel_init(),
                        KeyCode::Enter => app.init_submit(),
                        KeyCode::Backspace => app.init_input_backspace(),
                        KeyCode::Char(c) => app.init_input_char(c),
                        _ => {}
                    }
                } else if app.is_add_member_mode() {
                    // Handle add member mode
                    match key.code {
                        KeyCode::Esc => app.cancel_add_member(),
                        KeyCode::Enter => app.add_member_submit(),
                        KeyCode::Backspace => app.add_member_input_backspace(),
                        KeyCode::Char(c) => app.add_member_input_char(c),
                        _ => {}
                    }
                } else if app.is_navigate_dir_mode() {
                    // Handle directory navigation mode
                    if let Some(state) = &app.navigate_dir_state {
                        if state.input_mode {
                            // In input mode, handle text entry
                            match key.code {
                                KeyCode::Esc => app.navigate_dir_toggle_input(),
                                KeyCode::Enter => app.navigate_dir_enter(),
                                KeyCode::Backspace => app.navigate_dir_input_backspace(),
                                KeyCode::Char(c) => app.navigate_dir_input_char(c),
                                _ => {}
                            }
                        } else {
                            // In browse mode
                            match key.code {
                                KeyCode::Esc => app.cancel_navigate_dir(),
                                KeyCode::Up | KeyCode::Char('k') => app.navigate_dir_previous(),
                                KeyCode::Down | KeyCode::Char('j') => app.navigate_dir_next(),
                                KeyCode::Enter => app.navigate_dir_enter(),
                                KeyCode::Char('/') => app.navigate_dir_toggle_input(),
                                KeyCode::Char(' ') => app.navigate_dir_select(),
                                _ => {}
                            }
                        }
                    }
                } else if app.is_kudos_mode() {
                    // Handle kudos mode
                    match key.code {
                        KeyCode::Esc => app.cancel_kudos(),
                        KeyCode::Enter => app.kudos_submit(),
                        KeyCode::Backspace => app.kudos_input_backspace(),
                        KeyCode::Char(c) => app.kudos_input_char(c),
                        _ => {}
                    }
                } else if app.is_feedback_mode() {
                    // Handle feedback mode
                    match key.code {
                        KeyCode::Esc => app.cancel_feedback(),
                        KeyCode::Enter => app.feedback_submit(),
                        KeyCode::Backspace => app.feedback_input_backspace(),
                        KeyCode::Char(c) => app.feedback_input_char(c),
                        _ => {}
                    }
                } else {
                    match key.code {
                        KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
                        KeyCode::Tab => app.next_tab(),
                        KeyCode::BackTab => app.previous_tab(),
                        KeyCode::Up | KeyCode::Char('k') => {
                            if app.current_tab == app::Tab::Interactions {
                                app.previous_interaction();
                            } else {
                                app.previous_item();
                            }
                        }
                        KeyCode::Down | KeyCode::Char('j') => {
                            if app.current_tab == app::Tab::Interactions {
                                app.next_interaction();
                            } else {
                                app.next_item();
                            }
                        }
                        KeyCode::Left | KeyCode::Right
                            if app.current_tab == app::Tab::Interactions =>
                        {
                            app.toggle_interactions_view();
                        }
                        KeyCode::Char('1') | KeyCode::Char('2')
                            if app.current_tab == app::Tab::Interactions =>
                        {
                            app.next_subtab();
                        }
                        KeyCode::Enter => app.select_item(),
                        KeyCode::Char('a') if app.current_tab == app::Tab::Team => {
                            // Quick shortcut to add member when on Team tab
                            if app.team.is_some() {
                                app.start_add_member();
                            }
                        }
                        KeyCode::Char('o') => {
                            // Quick shortcut to open folder navigator
                            app.start_navigate_dir();
                        }
                        _ => {}
                    }
                }
            }
        }
    }
}
