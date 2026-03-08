{ inputs, pkgs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    ./ollama.nix

    inputs.niri.nixosModules.niri
    inputs.home-manager.nixosModules.home-manager

    {
      services.power-profiles-daemon.enable = true;
      services.upower.enable = true;
      znix.hardware.fingerprint.goodix.enable = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "hm-bak";
      home-manager.users.zerok.imports = [

        ./opencode.nix
        inputs.niri.homeModules.stylix
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
        inputs.nixvim.homeModules.nixvim
        ../../home
        {
          znix.browser.enable = true;
          znix.monitors = {
            list = {
              "eDP-1" = {
                mode = "1920x1080@60Hz";
                pos = "0 0";
              };
            };
            noctaliaMonitors = [ "eDP-1" ];
          };
          programs.noctalia-shell.settings.bar.position = "left";
          programs.alacritty.settings.font.size = 14;
        }
      ];
    }
  ];
}
