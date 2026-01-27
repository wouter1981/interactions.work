//! interactions TUI - Terminal User Interface for interactions.work

mod app;
mod ui;

use app::App;
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::prelude::*;
use std::{env, io, process};

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
                match key.code {
                    KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
                    KeyCode::Tab => app.next_tab(),
                    KeyCode::BackTab => app.previous_tab(),
                    KeyCode::Up | KeyCode::Char('k') => app.previous_item(),
                    KeyCode::Down | KeyCode::Char('j') => app.next_item(),
                    KeyCode::Enter => app.select_item(),
                    _ => {}
                }
            }
        }
    }
}
