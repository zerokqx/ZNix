use serde::Deserialize;

#[derive(Debug, Deserialize, Clone, Eq, PartialEq)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Action {
    Link {
        label: String,
        url: String,
    },
    NixRun {
        label: String,
        target: String,
        #[serde(default)]
        args: Vec<String>,
    },
    Command {
        label: String,
        #[serde(alias = "command")]
        target: String,
        #[serde(default)]
        args: Vec<String>,
    },
    SmartInstall {
        label: String,
        #[serde(default = "default_repo_url")]
        repo_url: String,
    },
}

fn default_repo_url() -> String {
    "https://github.com/zerokqx/ZNix.git".to_string()
}

#[derive(Debug, Deserialize)]
pub struct Config {
    pub items: Vec<Action>,
}
