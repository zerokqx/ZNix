{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./core
    ./configs
  ];
  programs.wireshark.enable = true;
  programs.bash.enable = true;
  zramSwap.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = false;
  };
  networking.firewall = {
    enable = lib.mkForce false;
    allowedTCPPorts = [
      27015
      52385
    ];
    allowedUDPPorts = [
      27015
      5353
    ];
  };
  services.gnome.gcr-ssh-agent.enable = false;
  znix.dev.ports.enable = true;
  security.polkit.enable = true;
  services.upower.enable = true;
  documentation.man.cache.enable = false;
  programs.command-not-found.enable = false;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  # programs.sway = {
  #   enable = true;
  #   package = pkgs.swayfx;
  # };
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  environment.variables.EDITOR = "nvim";
  programs.gnupg.agent.enable = true;
  programs = {
    nix-ld.enable = true;
    # light.enable = true;
    fish.enable = true;
    direnv.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
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
    dbus.enable = true;
    playerctld.enable = true;
  };

  programs.ssh.startAgent = lib.mkForce true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  fonts.packages = with pkgs; [
    corefonts
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

  programs.localsend.enable = true;
  environment.systemPackages = with pkgs; [ ];
}
