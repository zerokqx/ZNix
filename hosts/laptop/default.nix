{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix
    ./hardware-configuration.nix
    ./fprintd.nix

    inputs.home-manager.nixosModules.home-manager
    {

      home-manager = {
        extraSpecialArgs = { inherit inputs; };
      };
      home-manager.users.zerok.imports = [

        inputs.stylix.homeModules.stylix
        ../../home

        {
          programs.alacritty.settings.font.size = 14;
          wayland.windowManager.sway.config.output = {
            eDP-1 = {
              mode = "1920x1080@60Hz";
              pos = "0 0";
            };
          };
        }

        inputs.spicetify-nix.homeManagerModules.default
        inputs.nixvim.homeModules.nixvim
        inputs.noctalia.homeModules.default
      ];
    }
  ];
}
