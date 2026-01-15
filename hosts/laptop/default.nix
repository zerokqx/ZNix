{ inputs, ... }:
let
  gAttr = import ../general-attr.nix;
in
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    {

      home-manager.users.zerok.imports = [
        ../../home

        {
          wayland.windowManager.sway.config.output = {
            eDP-1 = {
              mode = "1920x1080@60Hz";
              pos = "0 0";
            };
          };
        }
        inputs.nixvim.homeManagerModules.nixvim
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
      ];
    }
  ]
  ++ gAttr.general-path;
}
