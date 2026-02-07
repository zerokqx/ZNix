{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    ./ollama.nix

    inputs.home-manager.nixosModules.home-manager

    {
      znix.hardware.fingerprint.goodix.enable = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "hm-bak";
      home-manager.users.zerok.imports = [

        ./opencode.nix
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
