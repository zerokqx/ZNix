{ lib, pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    # Model presets for built-in OpenAI OAuth and the Antigravity plugin.
    # https://github.com/NoeFabris/opencode-antigravity-auth#models
    settings = builtins.fromJSON (builtins.readFile ./opencode.json);
  };

  home.file.".config/opencode/skills".source = ./opencode-skills;


  # home.activation.installOpenCodePlugins = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
  #   if ! ${pkgs.nodejs_22}/bin/node -e '
  #     const base = process.env.HOME + "/.config/opencode/node_modules/";
  #     process.exit(
  #       require(base + "opencode-antigravity-auth/package.json").version === "1.6.0" ? 0 : 1
  #     );
  #   ' 2>/dev/null; then
  #     ${pkgs.nodejs_22}/bin/npm install --prefix "$HOME/.config/opencode" \
  #       --no-save --no-audit --no-fund \
  #       opencode-antigravity-auth@1.6.0
  #   fi
  # '';
}
