{ inputs, lib, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.home-manager.nixosModules.home-manager

    {

      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
      znix.hardware.fingerprint.goodix.enable = false;
      home-manager.useGlobalPkgs = true;

      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "hm-bak";
      home-manager.users.zerok.imports = [

        inputs.stylix.homeModules.stylix
        inputs.dms.homeModules.dank-material-shell
        inputs.noctalia.homeModules.default
        inputs.nixvim.homeModules.nixvim
        ../../home
        {
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
          programs.noctalia-shell.settings.bar.position = "bottom";
        }
      ];
    }
  ];
}
