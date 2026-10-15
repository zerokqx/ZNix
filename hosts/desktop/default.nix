{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix
    inputs.codex-desktop-linux.nixosModules.default
    ./hardware-configuration.nix
    ./virtual.nix
    ./wine.nix
    {
      networking.hostName = "nixos-pc";
      programs.codexDesktopLinux.enable = true;
      home-manager.users.zerok = {
        wayland.windowManager.hyprland.settings = {
          monitor = [
            "DP-1,1920x1080@165,1920x0,1"
            "HDMI-A-1,1920x1080@75,0x0,1"
          ];
          workspace = [
            "2,monitor:DP-1"
            "3,monitor:HDMI-A-1"
            "9,monitor:HDMI-A-1"
          ];
        };
      };
    }
  ];
}
