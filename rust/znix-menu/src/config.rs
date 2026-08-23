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
}

#[derive(Debug, Deserialize)]
pub struct Config {
    pub items: Vec<Action>,
}
