{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ../core/ly.nix
    ../core/pipewire.nix
    ../core/graphics.nix
    ../core/bluetooth.nix
    ../core/flatpak.nix
  ];

  services.input-remapper.enable = true;
  environment.systemPackages = [
    pkgs.polkit_gnome
    pkgs.xdg-utils
  ];

  programs = {
    hyprland.enable = true;
    hyprland.withUWSM = true;
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
    gamescope.enable = true;
    localsend.enable = true;
    gamemode.enable = true;
  };
}
