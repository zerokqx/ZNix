{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    {
      home-manager.users.zerok = {
        znix.browser.enable = true;

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
