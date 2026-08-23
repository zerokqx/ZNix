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
        znix.monitors = {
          noctaliaMonitors = [ ];
          list = {
            "DP-1" = {
              mode = "1920x1080@165Hz";
              pos = "1920 0";
            };
            "HDMI-A-1" = {
              mode = "1920x1080@75Hz";
              pos = "0 0";
            };
          };
        };
        programs.noctalia-shell.settings.bar.position = "bottom";
      };
    }
  ];
}
