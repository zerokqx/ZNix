use std::error::Error;
use std::process::{Command, Stdio};
use std::thread::sleep;
use std::time::Duration;

pub fn handle_nix_run(label: &str, target: &str, args: &[String]) -> Result<(), Box<dyn Error>> {
    let sp = cliclack::spinner();
    sp.start(format!("Preparing {target}..."));

    let mut cmd = Command::new("nix");
    cmd.arg("run").arg(target);

    if !args.is_empty() {
        cmd.arg("--").args(args);
    }

    sp.stop(format!("Running {label}..."));

    let status = cmd
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status();

    match status {
        Ok(s) if s.success() => {
            cliclack::log::success(format!("{label} finished successfully"))?;
        }
        _ => {
            cliclack::log::error(format!("Failed to execute {label}"))?;
        }
    }

    sleep(Duration::from_millis(1000));
    Ok(())
}
