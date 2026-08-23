use crate::utils::{clear_terminal, expand_path};
use cliclack::{intro, log, note};
use std::error::Error;
use std::fs;
use std::process::{Command, Stdio};
use std::thread::sleep;
use std::time::Duration;

pub fn handle_smart_install(repo_url: &str) -> Result<(), Box<dyn Error>> {
    clear_terminal();
    intro("✨ ZNix Smart Installer")?;

    // 1. Спрашиваем куда клонировать
    let default_dest = "~/projects/ZNix";
    let dest_input: String = cliclack::input("Where to clone ZNix repository?")
        .placeholder(default_dest)
        .default_input(default_dest)
        .interact()?;
    let dest_path = expand_path(&dest_input);

    // 2. Спрашиваем целевой хост (desktop / laptop)
    let host: &str = cliclack::select("Select Target Host profile")
        .item("desktop", "🖥️  Desktop (PC / Dual Monitor)", "DP-1 @ 165Hz & HDMI @ 75Hz")
        .item("laptop", "💻 Laptop (Battery & Goodix Fingerprint)", "1080p @ 60Hz & power savings")
        .interact()?;

    // 3. Спрашиваем где брать hardware-configuration.nix
    let hw_choice: &str = cliclack::select("Where to find hardware-configuration.nix?")
        .item("auto", "⚡ Auto-generate now (runs sudo nixos-generate-config)", "Recommended for fresh installs")
        .item("default", "📂 Copy existing from /etc/nixos/hardware-configuration.nix", "If system is already configured")
        .item("custom", "✏️  Specify custom path", "Enter file path manually")
        .interact()?;

    let hw_content: String = match hw_choice {
        "auto" => {
            let sp = cliclack::spinner();
            sp.start("Generating hardware-configuration.nix via sudo...");
            let output = Command::new("sudo")
                .arg("nixos-generate-config")
                .arg("--show-hardware-config")
                .output();

            match output {
                Ok(out) if out.status.success() => {
                    sp.stop("Hardware configuration generated successfully");
                    String::from_utf8_lossy(&out.stdout).to_string()
                }
                _ => {
                    sp.error("Failed to generate with sudo. Falling back to /etc/nixos...");
                    fs::read_to_string("/etc/nixos/hardware-configuration.nix")
                        .map_err(|e| format!("Could not read /etc/nixos/hardware-configuration.nix: {e}"))?
                }
            }
        }
        "default" => {
            fs::read_to_string("/etc/nixos/hardware-configuration.nix")
                .map_err(|e| format!("Could not find /etc/nixos/hardware-configuration.nix: {e}"))?
        }
        "custom" => {
            let custom_path: String = cliclack::input("Enter path to hardware-configuration.nix:")
                .placeholder("/path/to/hardware-configuration.nix")
                .interact()?;
            let expanded_custom = expand_path(&custom_path);
            fs::read_to_string(&expanded_custom)
                .map_err(|e| format!("Could not read file at {}: {e}", expanded_custom.display()))?
        }
        _ => unreachable!(),
    };

    // 4. Клонируем репозиторий
    let sp = cliclack::spinner();
    if dest_path.exists() && dest_path.join(".git").exists() {
        sp.start(format!("Repository already exists at {}. Updating...", dest_path.display()));
        let _ = Command::new("git")
            .arg("-C")
            .arg(&dest_path)
            .arg("pull")
            .output();
        sp.stop("Repository up to date");
    } else {
        sp.start(format!("Cloning {repo_url} into {}...", dest_path.display()));
        if let Some(parent) = dest_path.parent() {
            fs::create_dir_all(parent)?;
        }
        let status = Command::new("git")
            .arg("clone")
            .arg(repo_url)
            .arg(&dest_path)
            .status()?;
        if !status.success() {
            sp.error("Git clone failed");
            return Err("Git clone failed".into());
        }
        sp.stop("Repository cloned successfully");
    }

    // 5. Записываем hardware-configuration.nix в целевой хост
    let target_hw_file = dest_path.join("hosts").join(host).join("hardware-configuration.nix");
    if let Some(parent) = target_hw_file.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&target_hw_file, hw_content)?;
    log::success(format!("Wrote hardware configuration to {}", target_hw_file.display()))?;

    // 6. Уведомление и предложение переключиться
    note(
        "Installation Ready!",
        format!(
            "ZNix repository is set up at {}\nHost: {}\nHardware config: {}",
            dest_path.display(),
            host,
            target_hw_file.display()
        ),
    )?;

    let should_switch = cliclack::confirm("Do you want to build and switch to ZNix now?")
        .initial_value(true)
        .interact()?;

    if should_switch {
        let sp = cliclack::spinner();
        sp.start("Building and activating ZNix...");
        let mut cmd = Command::new("nh");
        cmd.arg("os")
            .arg("switch")
            .arg(&dest_path);

        let status = cmd
            .stdin(Stdio::inherit())
            .stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .status();

        match status {
            Ok(s) if s.success() => {
                sp.stop("ZNix activated successfully!");
                log::success("Welcome to ZNix! 🎉")?;
            }
            _ => {
                sp.error("nh os switch failed. Try running 'nh os switch .' manually inside the repo");
            }
        }
    } else {
        log::info(format!("To activate later, run: cd {} && nh os switch .", dest_path.display()))?;
    }

    sleep(Duration::from_millis(2000));
    Ok(())
}
