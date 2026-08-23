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

    // 2. Спрашиваем имя хоста (машины)
    let host_name: String = cliclack::input("Enter hostname for this machine:")
        .placeholder("my-pc")
        .default_input("desktop")
        .interact()?;

    // 3. Спрашиваем где брать hardware-configuration.nix
    let hw_choice: &str = cliclack::select("Where to find hardware-configuration.nix?")
        .item("auto", "⚡ Auto-generate now (runs sudo nixos-generate-config)", "Recommended for fresh installs")
        .item("default", "📂 Copy existing from /etc/nixos/hardware-configuration.nix", "If system is already configured")
        .item("custom", "✏️  Specify custom path", "Enter file path manually")
        .interact()?;

    let hw_content: String = match hw_choice {
        "auto" => {
            // Запрашиваем sudo интерактивно, чтобы пользователь мог ввести пароль
            let _ = Command::new("sudo")
                .arg("-v")
                .stdin(Stdio::inherit())
                .stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .status();

            let sp = cliclack::spinner();
            sp.start("Generating hardware-configuration.nix via nixos-generate-config...");
            let output = Command::new("sudo")
                .arg("nixos-generate-config")
                .arg("--show-hardware-config")
                .output()
                .or_else(|_| {
                    Command::new("nixos-generate-config")
                        .arg("--show-hardware-config")
                        .output()
                });

            match output {
                Ok(out) if !out.stdout.is_empty() => {
                    sp.stop("Hardware configuration generated successfully");
                    String::from_utf8_lossy(&out.stdout).to_string()
                }
                _ => {
                    sp.error("Failed to auto-generate. Falling back to /etc/nixos/hardware-configuration.nix...");
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

    // 4. Клонируем репозиторий (если еще не склонирован)
    if !dest_path.exists() {
        let sp = cliclack::spinner();
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

    // 5. Проверяем, существует ли уже такой хост (защита от случайного затирания)
    let target_host_dir = dest_path.join("hosts").join(&host_name);
    if target_host_dir.exists() && target_host_dir.join("default.nix").exists() {
        let overwrite = cliclack::confirm(format!(
            "⚠️ Host '{}' already exists in {}/hosts/. Overwrite host files?",
            host_name,
            dest_path.display()
        ))
        .initial_value(false)
        .interact()?;

        if !overwrite {
            log::warning("Installation aborted to protect your existing host configuration.")?;
            sleep(Duration::from_millis(1500));
            return Ok(());
        }
    }

    // 5. Создаем хост на основе шаблона hosts/noop
    fs::create_dir_all(&target_host_dir)?;

    // Копируем Home-Manager профиль из home/noop в home/<host_name>
    let target_home_dir = dest_path.join("home").join(&host_name);
    fs::create_dir_all(&target_home_dir)?;

    let noop_home_default = dest_path.join("home").join("noop").join("default.nix");
    let target_home_default = target_home_dir.join("default.nix");
    if noop_home_default.exists() {
        fs::copy(&noop_home_default, &target_home_default)?;
        log::success(format!("Created Home-Manager config at {}", target_home_default.display()))?;
    }

    let noop_default = dest_path.join("hosts").join("noop").join("default.nix");
    let target_default = target_host_dir.join("default.nix");
    if noop_default.exists() {
        let content = fs::read_to_string(&noop_default)?;
        let updated_content = content.replace("../../home/noop", &format!("../../home/{host_name}"));
        fs::write(&target_default, updated_content)?;
    }

    // 6. Записываем hardware-configuration.nix
    let target_hw_file = target_host_dir.join("hardware-configuration.nix");
    fs::write(&target_hw_file, hw_content)?;
    log::success(format!("Host '{}' configured with hardware config at {}", host_name, target_hw_file.display()))?;

    // 7. Добавляем скрипты ребилда в devenv.nix
    let devenv_file = dest_path.join("devenv.nix");
    if devenv_file.exists() {
        if let Ok(content) = fs::read_to_string(&devenv_file) {
            let script_target = format!("scripts.rebuild-{host_name}.exec");
            if !content.contains(&script_target) {
                let new_script_lines = format!(
                    "  scripts.rebuild-{host_name}.exec = \"git add . && sudo nixos-rebuild switch --flake .#{host_name} --show-trace\";\n  scripts.rebuild-{host_name}-test.exec = \"git add . && sudo nixos-rebuild test --flake .#{host_name} --show-trace\";\n"
                );
                let updated = if let Some(pos) = content.find("scripts.theme-link-git") {
                    let mut s = content.clone();
                    s.insert_str(pos, &new_script_lines);
                    s
                } else if let Some(pos) = content.find("enterShell") {
                    let mut s = content.clone();
                    s.insert_str(pos, &new_script_lines);
                    s
                } else {
                    content
                };
                let _ = fs::write(&devenv_file, updated);
                log::success(format!("Added 'rebuild-{host_name}' to devenv.nix"))?;
            }
        }
    }

    // 8. Уведомление и предложение переключиться
    note(
        "Installation Ready!",
        format!(
            "ZNix repository is ready at {}\nTarget Host: {}\nHost config: {}\nHome config: {}",
            dest_path.display(),
            host_name,
            target_default.display(),
            target_home_default.display()
        ),
    )?;

    let should_switch = cliclack::confirm(format!("Do you want to build and switch to host '{}' now?", host_name))
        .initial_value(true)
        .interact()?;

    if should_switch {
        let sp = cliclack::spinner();
        sp.start(format!("Building and activating host '{}'...", host_name));
        let mut cmd = Command::new("nh");
        cmd.arg("os")
            .arg("switch")
            .arg(&dest_path)
            .arg("--hostname")
            .arg(&host_name);

        let status = cmd
            .stdin(Stdio::inherit())
            .stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .status();

        match status {
            Ok(s) if s.success() => {
                sp.stop("ZNix activated successfully!");
                log::success(format!("Welcome to ZNix on '{}'! 🎉", host_name))?;
            }
            _ => {
                sp.error(format!("nh os switch failed. Try running 'nh os switch . --hostname {}' manually inside the repo", host_name));
            }
        }
    } else {
        log::info(format!("To activate later, run: cd {} && nh os switch . --hostname {}", dest_path.display(), host_name))?;
    }

    sleep(Duration::from_millis(2000));
    Ok(())
}
