{ config, ... }:
{

  home.file."${config.home.homeDirectory}/projects/.keep" = {
    text = "";
  };
  home.file.".config/quickshell".source = builtins.toAbsolutePath ./pkgs-configuration/qucikshell;
  home.file.".config/quickshell".recursive = true;
}
