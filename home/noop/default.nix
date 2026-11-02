{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../zerokqx/hyprland
    ../zerokqx/nixvim
    ../zerokqx/dms.nix
    ../zerokqx/znix
    ../zerokqx/foot.nix
    ../zerokqx/fish.nix
    ../zerokqx/zoxide.nix
    ../zerokqx/git.nix
    ../zerokqx/mimes.nix
    ../zerokqx/packages.nix
    ../zerokqx/chromium.nix
    ../zerokqx/dir-file-create.nix
  ];

  home.username = lib.mkDefault "zerok";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;
  home.packages = with pkgs; [ ];

  services.ssh-agent.enable = true;
  services.udiskie = {
    enable = true;
    settings = {
      automount = true;
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.dotnet/tools"
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.sessionVariables = {
    TERMINAL = "foot";
    TERM = "xterm-256color";
    BROWSER = "chromium";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  znix.monitors = {
    list = lib.mkDefault { };
  };

  programs.home-manager.enable = true;
}
