{ lib, config, ... }:

lib.mkIf config.plugins.blink-cmp.enable {
  plugins.blink-cmp-git.enable = builtins.trace "Git cmp включен" true;

  plugins.blink-cmp.settings.sources.providers.git = {
    module = "blink-cmp-git";
    name = "git";
    score_offset = 100;
    opts = {
      commit = { };
      git_centers.github = { }; # было git_hub → исправил
    };
  };
}
