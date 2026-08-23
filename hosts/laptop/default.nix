{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    {
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
      znix.hardware.fingerprint.goodix.enable = false;

      home-manager.users.zerok = {
        programs.dank-material-shell.enable = true;
        znix.browser.enable = true;
        znix.monitors = {
          list = {
            "eDP-1" = {
              mode = "1920x1080@60Hz";
              pos = "0 0";
            };
            "HDMI-A-2" = {
              mode = "1920x1080@60Hz";
              pos = "1920x0";
            };
          };
          noctaliaMonitors = [
            "eDP-1"
            "HDMI-A-2"
          ];
        };
      };
    }
  ];
}
