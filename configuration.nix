{ config, pkgs, ... }:
{
  imports = [
    ./core
    ./configs
  ];
  programs.bash.enable = true;
  dev.ports.enable = true;
  virtualisation.docker.enable = true;
  security.polkit.enable = true;
  services.upower.enable = true;
  documentation.man.generateCaches = false;
  programs.command-not-found.enable = false;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
  };
  security.pam.services.swaylock = { };
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  programs.kdeconnect.enable = true;
  environment.variables.EDITOR = "nvim";
  programs.gnupg.agent.enable = true;
  programs = {
    nix-ld.enable = true;
    light.enable = true;
    fish.enable = true;
    direnv.enable = true;
    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
        args = [
          "-O"
          "DP-1"
        ];
      };
    };
    gamescope = {
      enable = true;

    };
  };

  services = {
    displayManager.ly.enable = true;
    dbus.enable = true;
    playerctld.enable = true;
    flatpak.enable = true;
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  fonts.packages = with pkgs; [
    maple-mono.CN
    maple-mono."CN-unhinted"
    maple-mono.NF
    maple-mono."NF-CN"
  ];

  nix.gc = {
    automatic = true;
    dates = "03:15";
    options = "--delete-older-than 7d";
  };
  system.stateVersion = "25.05";
}
