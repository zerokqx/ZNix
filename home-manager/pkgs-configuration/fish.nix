{ pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting ""
    '';
    plugins = [{
      name = "plugin-git";
      src = pkgs.fishPlugins.plugin-git.src;
    }];
    shellAliases = {
      rbl-flake = "sudo nixos-rebuild switch --flake /etc/nixos/";
      conf = "sudo micro /etc/nixos/configuration.nix";
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
      gpsh = "git push";
      gcm = "git commit -m";
      gsw = "git switch";
      add = "git add";
      gal = "git add .";
      gpl = "git pull";

    };
  };
  home.packages = with pkgs; [

    fishPlugins.fish-you-should-use
    fishPlugins.plugin-git
    fishPlugins.done
    fishPlugins.autopair

  ];
}
