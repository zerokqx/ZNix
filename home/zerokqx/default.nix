{
  config,
  lib,
  ...
}:
{
  imports = [
    ./translate-shell.nix
    ./obs-studio.nix
    ./opencode.nix
    ./hyprland
    ./mimes.nix
    ./git.nix
    ./dms.nix
    ./znix
    ./zoxide.nix
    ./foot.nix
    ./fish.nix
    ./nixvim
    ./packages.nix
    ./spicetify.nix
    ./chromium.nix
    ./dir-file-create.nix
  ];

  home.username = "zerok";
  home.homeDirectory = "/home/zerok";
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;
  home.language = {
    numeric = "ru_RU.UTF-8";
    time = "ru_RU.UTF-8";
    base = "en_US.UTF-8";
    address = "en_US.UTF-8";
    messages = "en_US.UTF-8";
    telephone = "en_US.UTF-8";
  };

  services.ssh-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      vpn = {
        HostName = "89.125.54.155";
        User = "root";
        Port = 443;
        IdentityFile = "~/.ssh/id_ed25519";
      };
      thinkpad = {
        HostName = "192.168.1.13";
        User = "zerok";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "Host * !vpn !thinkpad" = {
        IdentityFile = "~/.ssh/id_ed25519_sk_rk";
        IdentitiesOnly = true;
      };
    };
  };
  services.udiskie = {
    enable = true;
    settings = {
      automount = true;
    };
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"

    "${config.home.homeDirectory}/.local/share/pnpm/bin"
    "${config.home.homeDirectory}/.bun/bin"
    "${config.home.homeDirectory}/.dotnet/tools"
    "${config.home.homeDirectory}/.local/bin"
  ];
  home.sessionVariables = {
    TERMINAL = "foot";
    TERM = "xterm-256color";
    BROWSER = "chromium";
    QT_QPA_PLATFORMTHEME = lib.mkForce "xdgdesktopportal";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.home-manager.enable = true;
}
