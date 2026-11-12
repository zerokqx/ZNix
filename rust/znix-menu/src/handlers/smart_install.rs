use crate::utils::{clear_terminal, expand_path};
use cliclack::{intro, log, note};
use std::error::Error;
use std::fs::{self, File};
use std::io::{self, Write};
use std::path::Path;
use std::process::Command;

const REGISTRY: &str = "hosts/default.nix";
const REGISTRY_LOCK: &str = "hosts/.znix-installer.lock";
const INSTALL_SYSTEM: &str = "x86_64-linux";

pub fn handle_smart_install(repo_url: &str) -> Result<(), Box<dyn Error>> {
    clear_terminal();
    intro("✨ ZNix Smart Installer")?;

    let host_name: String = cliclack::input("Enter hostname for this machine:")
        .placeholder("my-pc")
        .interact()?;
    validate_hostname(&host_name)?;

    let system = output(
        Command::new("nix").args([
            "eval",
            "--raw",
            "--impure",
            "--expr",
            "builtins.currentSystem",
        ]),
        "identify the local Nix platform",
    )?;
    if system.trim() != INSTALL_SYSTEM {
        return Err(format!(
            "The installer supports {INSTALL_SYSTEM}. Register this machine manually in {REGISTRY} with system {:?}.",
            system.trim()
        ).into());
    }

    let default_dest = "~/projects/ZNix";
    let dest_input: String = cliclack::input("Where to clone ZNix repository?")
        .placeholder(default_dest)
        .default_input(default_dest)
        .interact()?;
    let dest_path = expand_path(&dest_input);

    if !dest_path.try_exists()? {
        if let Some(parent) = dest_path
            .parent()
            .filter(|path| !path.as_os_str().is_empty())
        {
            fs::create_dir_all(parent)?;
        }
        run(
            Command::new("git")
                .arg("clone")
                .arg("--")
                .arg(repo_url)
                .arg(&dest_path),
            "clone ZNix",
        )?;
    }
    let repo = fs::canonicalize(dest_path)?;
    let git_root = output(
        git(&repo).args(["rev-parse", "--show-toplevel"]),
        "find Git root",
    )?;
    if fs::canonicalize(git_root.trim())? != repo {
        return Err("Choose the root of the ZNix Git checkout.".into());
    }
    let checkout_was_clean = checkout_unchanged(&repo, &[])?;

    let registry_path = repo.join(REGISTRY);
    for directory in ["hosts", "home"] {
        if !fs::symlink_metadata(repo.join(directory))?.is_dir() {
            return Err(
                format!("Expected a directory at {directory} in the ZNix checkout.").into(),
            );
        }
    }
    if !fs::symlink_metadata(&registry_path)?.is_file() {
        return Err(format!("Expected a regular registry file at {REGISTRY}.").into());
    }

    let host_dir = format!("hosts/{host_name}");
    let home_dir = format!("home/{host_name}");
    let tracked = output(
        git(&repo).args(["ls-files", "--", &host_dir, &home_dir]),
        "check for existing Git paths",
    )?;
    if !tracked.is_empty() {
        return Err(format!("Git already tracks files for '{host_name}'. Edit the existing configuration or use a different name.").into());
    }
    ensure_absent(&repo.join(&host_dir))?;
    ensure_absent(&repo.join(&home_dir))?;

    let original_registry = fs::read_to_string(&registry_path)?;
    let registry_matches_head = checkout_was_clean
        && original_registry
            == output(
                git(&repo).args(["show", &format!("HEAD:{REGISTRY}")]),
                "read the committed registry",
            )?;
    let updated_registry = register(&original_registry, &host_name)?;
    for collection in ["nixosConfigurations", "homeConfigurations"] {
        let names = output(
            Command::new("nix").current_dir(&repo).args([
                "eval",
                "--no-update-lock-file",
                "--json",
                &format!(".#{collection}"),
                "--apply",
                "builtins.attrNames",
            ]),
            "check registered output names",
        )?;
        if serde_json::from_str::<Vec<String>>(&names)?.contains(&host_name) {
            return Err(format!("{collection}.{host_name} already exists. Edit the existing configuration or use a different name.").into());
        }
    }

    let hardware = hardware_config()?;
    let files = [
        (format!("{host_dir}/default.nix"), host_module(&host_name)),
        (format!("{host_dir}/hardware-configuration.nix"), hardware),
        (
            format!("{home_dir}/default.nix"),
            "{\n  imports = [ ../noop ];\n}\n".to_owned(),
        ),
        (REGISTRY.to_owned(), updated_registry),
    ];

    write_config(&repo, [&host_dir, &home_dir], &files, &original_registry)?;

    let paths = files
        .iter()
        .map(|(path, _)| path.as_str())
        .collect::<Vec<_>>();
    note(
        "Review generated files",
        format!(
            "Repository: {}\n{}\n\nTo stage from the repository root:\n  git add -- {}\nTo build:\n  ./scripts/rebuild.sh build {host_name}\nTo activate:\n  ./scripts/rebuild.sh switch {host_name}",
            repo.display(),
            paths.join("\n"),
            paths.join(" ")
        ),
    )?;

    if !registry_matches_head || !checkout_unchanged(&repo, &paths)? {
        log::info(
            "The checkout has other Git changes. Review and stage your intended changes, then build and activate manually.",
        )?;
        return Ok(());
    }

    let should_switch =
        cliclack::confirm("Stage the four listed files, build, and switch to this host now?")
            .initial_value(false)
            .interact()?;
    if should_switch {
        if !checkout_unchanged(&repo, &paths)? {
            return Err("Other Git changes appeared after generation. Review, stage, build, and activate manually.".into());
        }
        let mut index_args = vec!["diff", "--cached", "--quiet", "HEAD", "--"];
        index_args.extend(paths.iter().copied());
        if !git_unchanged(&repo, &index_args)? {
            return Err(
                "The Git index changed for the listed files. Review and stage them manually."
                    .into(),
            );
        }
        for (path, contents) in &files {
            let path = repo.join(path);
            if !fs::symlink_metadata(&path)?.is_file() || fs::read(&path)? != contents.as_bytes() {
                return Err(format!(
                    "{} changed after generation. Review it before staging.",
                    path.display()
                )
                .into());
            }
        }
        run(
            git(&repo).args(["add", "--"]).args(paths),
            "stage the four listed files",
        )?;
        run(
            Command::new("bash").current_dir(&repo).args([
                "./scripts/rebuild.sh",
                "build",
                &host_name,
            ]),
            "build the new host",
        )?;
        run(
            Command::new("bash").current_dir(&repo).args([
                "./scripts/rebuild.sh",
                "switch",
                &host_name,
            ]),
            "switch to the new host",
        )?;
        log::success(format!("Activated {host_name}"))?;
    }
    Ok(())
}

fn validate_hostname(name: &str) -> Result<(), Box<dyn Error>> {
    let bytes = name.as_bytes();
    let alphanumeric = |byte: &u8| byte.is_ascii_lowercase() || byte.is_ascii_digit();
    if bytes.len() <= 63
        && bytes.first().is_some_and(alphanumeric)
        && bytes.last().is_some_and(alphanumeric)
        && bytes.iter().all(|byte| alphanumeric(byte) || *byte == b'-')
    {
        Ok(())
    } else {
        Err("Use a hostname of 1–63 lowercase ASCII letters, digits, and hyphens, starting and ending with a letter or digit.".into())
    }
}

fn ensure_absent(path: &Path) -> Result<(), Box<dyn Error>> {
    match fs::symlink_metadata(path) {
        Ok(_) => Err(format!(
            "{} already exists. Edit the existing configuration or use a different name.",
            path.display()
        )
        .into()),
        Err(error) if error.kind() == io::ErrorKind::NotFound => Ok(()),
        Err(error) => Err(error.into()),
    }
}

fn register(source: &str, name: &str) -> Result<String, Box<dyn Error>> {
    let host_entry = format!(
        "      \"{name}\" = mkHost {{\n        system = \"{INSTALL_SYSTEM}\";\n        modules = [\n          ../profiles/workstation.nix\n          ../profiles/personal.nix\n          ./{name}\n        ];\n      }};\n"
    );
    let home_entry = format!(
        "    \"{name}\" = mkHome {{\n      system = \"{INSTALL_SYSTEM}\";\n      module = ../home/{name};\n    }};\n"
    );

    let mut output = String::new();
    let mut hosts = 0;
    let mut homes = 0;
    for line in source.split_inclusive('\n') {
        match line.trim() {
            "# znix-installer:hosts" => {
                output.push_str(&host_entry);
                hosts += 1;
            }
            "# znix-installer:homes" => {
                output.push_str(&home_entry);
                homes += 1;
            }
            _ => {}
        }
        output.push_str(line);
    }
    if hosts != 1 || homes != 1 {
        return Err(format!("Expected one host marker and one home marker in {REGISTRY}. Update the ZNix checkout before using the installer.").into());
    }
    Ok(output)
}

fn host_module(name: &str) -> String {
    format!(
        "{{\n  imports = [ ./hardware-configuration.nix ];\n  networking.hostName = \"{name}\";\n  home-manager.users.zerok = {{\n    imports = [ ../../home/{name} ];\n    programs.dank-material-shell.enable = true;\n  }};\n}}\n"
    )
}

fn hardware_config() -> Result<String, Box<dyn Error>> {
    let choice = cliclack::select("Where to find hardware-configuration.nix?")
        .item(
            "auto",
            "Auto-generate with nixos-generate-config",
            "For a fresh install",
        )
        .item(
            "default",
            "Copy /etc/nixos/hardware-configuration.nix",
            "For an existing system",
        )
        .item(
            "custom",
            "Specify a path",
            "Use a hardware configuration from another location",
        )
        .interact()?;

    let contents = match choice {
        "auto" => output(
            Command::new("sudo").args(["nixos-generate-config", "--show-hardware-config"]),
            "generate hardware configuration",
        )?,
        "default" => fs::read_to_string("/etc/nixos/hardware-configuration.nix")?,
        "custom" => {
            let path: String = cliclack::input("Enter path to hardware-configuration.nix:")
                .placeholder("/path/to/hardware-configuration.nix")
                .interact()?;
            fs::read_to_string(expand_path(&path))?
        }
        _ => unreachable!(),
    };
    if contents.trim().is_empty() {
        return Err("The hardware configuration is empty.".into());
    }
    Ok(contents)
}

fn write_config(
    repo: &Path,
    directories: [&str; 2],
    files: &[(String, String); 4],
    original_registry: &str,
) -> Result<(), Box<dyn Error>> {
    let lock = repo.join(REGISTRY_LOCK);
    let lock_file = File::create_new(&lock).map_err(|error| {
        if error.kind() == io::ErrorKind::AlreadyExists {
            format!("{REGISTRY_LOCK} already exists. Check whether another installer is running before removing it.")
        } else {
            format!("Could not lock the registry: {error}")
        }
    })?;
    let mut created_dirs = Vec::new();
    let mut created_files = Vec::new();
    let registry = repo.join(REGISTRY);
    let registry_temp =
        registry.with_extension(format!("znix-installer-{}.tmp", std::process::id()));
    let verify_registry = || -> Result<(), Box<dyn Error>> {
        if !fs::symlink_metadata(&registry)?.is_file()
            || fs::read(&registry)? != original_registry.as_bytes()
        {
            return Err(
                "The registry changed while preparing the configuration. Run the installer again."
                    .into(),
            );
        }
        Ok(())
    };
    let result = (|| {
        verify_registry()?;
        for directory in directories {
            let path = repo.join(directory);
            fs::create_dir(&path)?;
            created_dirs.push(path);
        }
        for (relative, contents) in files {
            let path = if relative == REGISTRY {
                registry_temp.clone()
            } else {
                repo.join(relative)
            };
            let mut file = File::create_new(&path)?;
            created_files.push(path);
            file.write_all(contents.as_bytes())?;
        }
        verify_registry()?;
        fs::rename(&registry_temp, &registry)?;
        Ok(())
    })();
    if result.is_err() {
        for path in created_files {
            let _ = fs::remove_file(path);
        }
        for path in created_dirs {
            let _ = fs::remove_dir(path);
        }
    }
    drop(lock_file);
    let unlocked = fs::remove_file(&lock);
    result.and_then(|()| {
        unlocked.map_err(|error| format!("Could not remove {REGISTRY_LOCK}: {error}").into())
    })
}

fn git(repo: &Path) -> Command {
    let mut git = Command::new("git");
    git.current_dir(repo).env("GIT_OPTIONAL_LOCKS", "0");
    git
}

fn checkout_unchanged(repo: &Path, generated_paths: &[&str]) -> Result<bool, Box<dyn Error>> {
    let status = output(
        git(repo)
            .args([
                "status",
                "--porcelain=v1",
                "--untracked-files=all",
                "--",
                ".",
            ])
            .args(
                generated_paths
                    .iter()
                    .map(|path| format!(":(exclude,literal){path}")),
            ),
        "check for other Git changes",
    )?;
    Ok(status.is_empty())
}

fn git_unchanged(repo: &Path, args: &[&str]) -> Result<bool, Box<dyn Error>> {
    match git(repo).args(args).status()?.code() {
        Some(0) => Ok(true),
        Some(1) => Ok(false),
        status => Err(format!("Could not check Git state (exit status {status:?}).").into()),
    }
}

fn output(command: &mut Command, action: &str) -> Result<String, Box<dyn Error>> {
    let result = command
        .output()
        .map_err(|error| format!("Could not {action}: {error}"))?;
    if !result.status.success() {
        return Err(format!(
            "Could not {action}: {}",
            String::from_utf8_lossy(&result.stderr).trim()
        )
        .into());
    }
    Ok(String::from_utf8(result.stdout)?)
}

fn run(command: &mut Command, action: &str) -> Result<(), Box<dyn Error>> {
    let status = command
        .status()
        .map_err(|error| format!("Could not {action}: {error}"))?;
    if !status.success() {
        return Err(format!("Could not {action}: {status}").into());
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn validates_hostnames_before_interpolating_them() {
        for name in ["x", "123", "my-pc", "linux-01"] {
            validate_hostname(name).unwrap();
        }
        for name in [
            "", "-pc", "pc-", "a/b", "../home", "a_b", "PC", "a\"b", "a\nb", "а",
        ] {
            assert!(validate_hostname(name).is_err(), "{name:?}");
        }
        assert!(validate_hostname(&"a".repeat(64)).is_err());
    }

    #[test]
    fn registers_host_and_home_at_unique_markers() {
        let registry = "    # znix-installer:homes\n      # znix-installer:hosts\n";
        let updated = register(registry, "123").unwrap();
        assert!(updated.contains("\"123\" = mkHost {"));
        assert!(updated.contains("          ./123\n"));
        assert!(updated.contains("\"123\" = mkHome {"));
        assert!(updated.contains("      module = ../home/123;"));
        assert!(updated.contains(registry.lines().next().unwrap()));
        assert!(host_module("123").contains("networking.hostName = \"123\";"));

        assert!(register("    # znix-installer:homes\n", "new").is_err());
        assert!(register(&registry.repeat(2), "new").is_err());
    }

    #[test]
    fn config_writes_protect_existing_files_and_roll_back_on_failure() {
        let repo = std::env::temp_dir().join(format!("znix-installer-test-{}", std::process::id()));
        fs::create_dir(&repo).unwrap();
        fs::create_dir(repo.join("hosts")).unwrap();
        fs::create_dir_all(repo.join("home/new")).unwrap();
        let registry = "    # znix-installer:homes\n      # znix-installer:hosts\n";
        let updated = register(registry, "new").unwrap();
        fs::write(repo.join(REGISTRY), registry).unwrap();
        fs::write(repo.join("home/new/default.nix"), "existing").unwrap();

        let dirs = ["hosts/new", "home/new"];
        let files = [
            ("hosts/new/default.nix".to_owned(), host_module("new")),
            (
                "hosts/new/hardware-configuration.nix".to_owned(),
                "{}".to_owned(),
            ),
            ("home/new/default.nix".to_owned(), "{}".to_owned()),
            (REGISTRY.to_owned(), updated.clone()),
        ];
        let lock = repo.join(REGISTRY_LOCK);
        fs::write(&lock, "another installer").unwrap();
        let error = write_config(&repo, dirs, &files, registry).unwrap_err();
        assert!(error.to_string().contains(REGISTRY_LOCK));
        assert_eq!(fs::read_to_string(&lock).unwrap(), "another installer");
        assert!(!repo.join("hosts/new").exists());
        assert_eq!(fs::read_to_string(repo.join(REGISTRY)).unwrap(), registry);
        fs::remove_file(&lock).unwrap();

        assert!(ensure_absent(&repo.join("home/new")).is_err());
        assert!(write_config(&repo, dirs, &files, registry).is_err());
        assert!(!lock.exists());
        assert!(!repo.join("hosts/new").exists());
        assert_eq!(
            fs::read_to_string(repo.join("home/new/default.nix")).unwrap(),
            "existing"
        );
        assert_eq!(fs::read_to_string(repo.join(REGISTRY)).unwrap(), registry);

        fs::remove_dir_all(repo.join("home/new")).unwrap();
        let changed_registry = format!("# Changed since preflight\n{registry}");
        fs::write(repo.join(REGISTRY), &changed_registry).unwrap();
        assert!(write_config(&repo, dirs, &files, registry).is_err());
        assert!(!lock.exists());
        assert!(dirs.iter().all(|dir| !repo.join(dir).exists()));
        assert_eq!(
            fs::read_to_string(repo.join(REGISTRY)).unwrap(),
            changed_registry
        );

        fs::write(repo.join(REGISTRY), registry).unwrap();
        write_config(&repo, dirs, &files, registry).unwrap();
        assert!(!lock.exists());
        for (path, contents) in files {
            assert_eq!(fs::read_to_string(repo.join(path)).unwrap(), contents);
        }
        fs::remove_dir_all(repo).unwrap();
    }
}
