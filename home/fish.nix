{ pkgs, lib, ... }:
{
  programs.nix-index.enableFishIntegration = true;
  programs.nix-index.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting ""
    '';
    plugins = [
      {
        name = "plugin-git";
        src = pkgs.fishPlugins.plugin-git.src;
      }
    ];
    shellAliases = {
      n = "nvim";
      cl = "clear";
      s = "sudo";
      cd = "z";
      sn = "sudo -e";
      ls = "eza";
      p = "pnpm";
      b = "bun";
      "cat" = "bat";
      bkp-sync = "rsync -avh --delete";
      bkp = "rsync -avh";
      ap = "apack";
      u = "aunpack";
    };
  };
  home.packages = with pkgs; [
    fishPlugins.done
    fishPlugins.autopair

  ];
}
