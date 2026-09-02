{ pkgs, ... }:
{
  home.packages = [ pkgs.translate-shell ];
  programs.fish = {
    shellAbbrs = {
      t = "trans -brief";
    };
    shellAliases = {

      "tfb" = ''trans -brief :ru "$(wl-paste)"'';
    };
  };
}
