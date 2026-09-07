{ pkgs, ... }:
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
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
    ];
    shellAbbrs = {
      init-commit = ''git commit -m "feat: initial commit"'';
      m = "moon";
      dal = "direnv allow";
      nsh = "nix shell";
      yz = "yazi";
      c = "cargo";
      p = "pnpm";
      d = "docker";
      dcp = "docker compose";
      dr = "docker run";
      xmod = "chmod +x";
      dps = "docker ps";
      di = "docker images";
      pf = "pnpm --filter";
      pcl = "pnpm store prune";
      pi = "pnpm install";
      pa = "pnpm add";
      pad = "pnpm add -D";
      paw = "pnpm add -w";
      prm = "pnpm remove";
      pup = "pnpm update";
      pr = "pnpm run";
      px = "pnpm dlx";
      pawd = "pnpm add  -wD";
      nx = "pnpm nx";
      nxm = "pnpm nx run-many -t";
      nxs = "pnpm nx serve";
      nxg = "pnpm nx g";
      nxr = "pnpm nx run";
      nxb = "pnpm nx build";
      nxt = "pnpm nx test";
      nxl = "pnpm nx lint";
      nxmt = "pnpm nx run-many -t test";
      nxrs = "pnpm nx reset";
      nxms = "pnpm nx run-many -t serve";
      nxmb = "pnpm nx run-many -t build";
      nxml = "pnpm nx run-many -t lint";
      nxmf = "pnpm nx run-many -t format:write";
    };
    shellAliases = {
      rmdir = "rm -rf";
      rm = "trash-put";
      undo = "trash-restore";
      trash = "trash-list";
      trash-clear = "trash-empty";
      n = "nvim";
      cl = "clear";
      s = "sudo";
      cd = "z";
      ls = "eza";
      b = "bun";
      "cat" = "bat";
      bkp-sync = "rsync -avh --delete";
      bkp = "rsync -avh";
      ap = "apack";
      u = "aunpack";
    };
  };
  home.packages = with pkgs; [
    grc
    fzf
  ];
}
