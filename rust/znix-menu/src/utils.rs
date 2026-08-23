use std::io::{self, Write};
use std::path::PathBuf;

pub fn clear_terminal() {
    print!("\x1B[2J\x1B[1;1H");
    let _ = io::stdout().flush();
}

pub fn expand_path(p: &str) -> PathBuf {
    if p.starts_with("~/") {
        if let Ok(home) = std::env::var("HOME") {
            return PathBuf::from(home).join(&p[2..]);
        }
    }
    PathBuf::from(p)
}
