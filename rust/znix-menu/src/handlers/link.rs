use std::error::Error;
use std::thread::sleep;
use std::time::Duration;

pub fn handle_link(label: &str, url: &str) -> Result<(), Box<dyn Error>> {
    let sp = cliclack::spinner();
    sp.start(format!("Opening {url}..."));

    if let Err(err) = open::that(url) {
        sp.error(format!("Failed to open link: {err}"));
    } else {
        sp.stop(format!("{label} opened"));
    }

    sleep(Duration::from_millis(700));
    Ok(())
}
