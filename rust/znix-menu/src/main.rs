mod config;

use crate::config::Action;
use cliclack::{intro, log, note, outro};
use std::fs;
use std::io::{self, Write};
use std::process::{Command, Stdio};
use std::thread::sleep;
use std::time::Duration;

fn clear_terminal() {
    print!("\x1B[2J\x1B[1;1H");
    let _ = io::stdout().flush();
}

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

        // Создаем селектор заново для каждой итерации
        let mut menu = cliclack::select("Action");

        for item in &config.items {
            match item {
                Action::Link { label, url } => {
                    menu = menu.item(item.clone(), format!("🔗 {label}"), url.as_str());
                }
                Action::NixRun { label, target, .. } => {
                    menu = menu.item(item.clone(), format!("❄️  {label}"), target.as_str());
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

        match selected_action {
            Action::Link { label, url } => {
                let sp = cliclack::spinner();
                sp.start(format!("Opening {url}..."));

                if let Err(err) = open::that(&url) {
                    sp.error(format!("Failed to open link: {err}"));
                } else {
                    sp.stop(format!("{label} opened"));
                }

                sleep(Duration::from_millis(700));
            }

            Action::NixRun {
                label,
                target,
                args,
            } => {
                let sp = cliclack::spinner();
                sp.start(format!("Preparing {target}..."));

                let mut cmd = Command::new("nix");
                cmd.arg("run").arg(&target);

                if !args.is_empty() {
                    cmd.arg("--").args(&args);
                }

                sp.stop(format!("Running {label}..."));

                let status = cmd
                    .stdin(Stdio::inherit())
                    .stdout(Stdio::inherit())
                    .stderr(Stdio::inherit())
                    .status();

                match status {
                    Ok(s) if s.success() => {
                        log::success(format!("{label} finished successfully"))?;
                    }
                    _ => {
                        log::error(format!("Failed to execute {label}"))?;
                    }
                }

                sleep(Duration::from_millis(1000));
            }
        }
    }

    Ok(())
}
