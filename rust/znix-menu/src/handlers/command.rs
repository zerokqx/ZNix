use std::error::Error;
use std::process::{Command, Stdio};
use std::thread::sleep;
use std::time::Duration;

pub fn handle_command(label: &str, target: &str, args: &[String]) -> Result<(), Box<dyn Error>> {
    let sp = cliclack::spinner();
    sp.start(format!("Preparing command..."));

    let mut cmd = if args.is_empty() && target.contains(' ') {
        let mut sh_cmd = Command::new("sh");
        sh_cmd.arg("-c").arg(target);
        sh_cmd
    } else {
        let mut direct_cmd = Command::new(target);
        if !args.is_empty() {
            direct_cmd.args(args);
        }
        direct_cmd
    };

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
