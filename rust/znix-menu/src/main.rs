mod config;
mod handlers;
mod utils;

use crate::config::Action;
use crate::handlers::{handle_command, handle_link, handle_nix_run, handle_smart_install};
use crate::utils::clear_terminal;
use cliclack::{intro, note, outro};
use std::fs;
use std::thread::sleep;
use std::time::Duration;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let file = fs::read_to_string("./config.json")
        .unwrap_or_else(|_| include_str!("../config.json").to_string());
    let config: config::Config = serde_json::from_str(&file)?;

    loop {
        clear_terminal();
        intro("ZNix Menu")?;

        note(
            "Controls",
            "• ↑ / ↓ — select item\n• Enter — execute action\n• Esc / Ctrl+C — exit",
        )?;

        let mut menu = cliclack::select("Action");

        for item in &config.items {
            match item {
                Action::Link { label, url } => {
                    menu = menu.item(item.clone(), format!("🔗 {label}"), url.as_str());
                }
                Action::NixRun { label, target, .. } => {
                    menu = menu.item(item.clone(), format!("❄️  {label}"), target.as_str());
                }
                Action::Command { label, target, .. } => {
                    menu = menu.item(item.clone(), format!("💻 {label}"), target.as_str());
                }
                Action::SmartInstall { label, repo_url } => {
                    menu = menu.item(item.clone(), format!("✨ {label}"), repo_url.as_str());
                }
            }
        }

        let selected_action = match menu.interact() {
            Ok(act) => act,
            Err(_) => {
                clear_terminal();
                outro("Goodbye!")?;
                break;
            }
        };

        let result = match selected_action {
            Action::Link { label, url } => handle_link(&label, &url),
            Action::NixRun { label, target, args } => handle_nix_run(&label, &target, &args),
            Action::Command { label, target, args } => handle_command(&label, &target, &args),
            Action::SmartInstall { repo_url, .. } => handle_smart_install(&repo_url),
        };

        if let Err(e) = result {
            cliclack::log::error(format!("Error: {e}"))?;
            sleep(Duration::from_millis(2000));
        }
    }

    Ok(())
}
