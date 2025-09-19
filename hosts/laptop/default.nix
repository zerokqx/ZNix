{ inputs, ... }:
let

  nixosSystem = import ../../utils/nixosSystem.nix { inherit inputs; };
  gAttr = import ../general-attr.nix;
in {

  laptop = nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.users.zerok.imports =
          [ ../../home-manager ./output-sway-rewrite.nix ];
      }
      gAttr.home-manager-settings
      ./hardware-configuration.nix
    ] ++ gAttr.general-path;
  };
}
