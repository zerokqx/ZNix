{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };

  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    ./fprintd.nix
    ./ollama.nix

    inputs.home-manager.nixosModules.home-manager

    {
      hardware.fingerprint.enable = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "hm-bak";

      home-manager.users.zerok.imports = [

        ./opencode.nix
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
        inputs.nixvim.homeModules.nixvim

        ../../home

        {

          programs.noctalia-shell.settings.bar.position = "left";
          programs.noctalia-shell.settings.bar.monitors = [ "eDP-1" ];
          programs.alacritty.settings.font.size = 14;
          wayland.windowManager.sway.config.output = {
            eDP-1 = {
              mode = "1920x1080@60Hz";
              pos = "0 0";
            };
          };
        }
      ];
    }
  ];
}
