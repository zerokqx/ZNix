mod config;
mod handlers;
mod utils;

use crate::config::Action;
use crate::handlers::{handle_command, handle_link, handle_nix_run, handle_smart_install};
use crate::utils::clear_terminal;
use cliclack::{intro, note, outro};
use std::ffi::OsString;
use std::fs;
use std::thread::sleep;
use std::time::Duration;

fn load_config(args: &[OsString]) -> Result<config::Config, Box<dyn std::error::Error>> {
    let file = match args {
        [] => include_str!("../config.json").to_string(),
        [flag, path] if flag == "--config" => fs::read_to_string(path)?,
        _ => return Err("Usage: znix-menu [--config PATH] (load only a trusted config)".into()),
    };
    Ok(serde_json::from_str(&file)?)
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<_> = std::env::args_os().skip(1).collect();
    if args.len() == 1 && (args[0] == "--help" || args[0] == "-h") {
        println!(
            "Usage: znix-menu [--config PATH]\nThe built-in menu is used by default. Custom configs can execute commands; load only trusted files."
        );
        return Ok(());
    }
    let config = load_config(&args)?;

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
            Action::NixRun {
                label,
                target,
                args,
            } => handle_nix_run(&label, &target, &args),
            Action::Command {
                label,
                target,
                args,
            } => handle_command(&label, &target, &args),
            Action::SmartInstall { repo_url, .. } => handle_smart_install(&repo_url),
        };

        if let Err(e) = result {
            cliclack::log::error(format!("Error: {e}"))?;
            sleep(Duration::from_millis(2000));
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::process::Command;

    #[test]
    fn embedded_config_ignores_ambient_file() {
        if std::env::var_os("ZNIX_TEST_AMBIENT_CONFIG").is_some() {
            let config = load_config(&[]).unwrap();
            assert!(!config.items.is_empty());
            return;
        }
        let dir = std::env::temp_dir().join(format!("znix-menu-ambient-{}", std::process::id()));
        fs::create_dir(&dir).unwrap();
        // The old loader fails on this untrusted working-directory file.
        fs::write(dir.join("config.json"), "not JSON").unwrap();
        let status = Command::new(std::env::current_exe().unwrap())
            .args(["--exact", "tests::embedded_config_ignores_ambient_file"])
            .env("ZNIX_TEST_AMBIENT_CONFIG", "1")
            .current_dir(&dir)
            .status()
            .unwrap();
        fs::remove_dir_all(dir).unwrap();
        assert!(status.success());
    }

    #[test]
    fn explicit_config_preserves_actions_and_reports_errors() {
        let dir = std::env::temp_dir().join(format!("znix-menu-explicit-{}", std::process::id()));
        fs::create_dir(&dir).unwrap();
        let path = dir.join("мой конфиг.json");
        let args = [OsString::from("--config"), path.clone().into_os_string()];
        assert!(load_config(&args).is_err());
        fs::write(
            &path,
            r#"{"items":[{"type":"command","label":"Custom","target":"printf hello"}]}"#,
        )
        .unwrap();
        let config = load_config(&args).unwrap();
        assert!(
            matches!(&config.items[0], Action::Command { target, .. } if target == "printf hello")
        );
        fs::write(&path, "not JSON").unwrap();
        assert!(load_config(&args).is_err());
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn config_requires_an_explicit_complete_flag() {
        for args in [
            vec![OsString::from("config.json")],
            vec![OsString::from("--config")],
            vec![OsString::from("--unknown"), OsString::from("config.json")],
        ] {
            assert!(load_config(&args).is_err());
        }
    }
}
