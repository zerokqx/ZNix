{ lib, config, ... }:

lib.mkIf config.plugins.blink-cmp.enable {
  plugins.blink-cmp-git.enable = true;

  plugins.blink-cmp.settings.sources.providers.git = {
    module = "blink-cmp-git";
    name = "git";
    score_offset = 100;
    opts = {
      commit = { };
      git_centers.github = { };
    };
  };
}
