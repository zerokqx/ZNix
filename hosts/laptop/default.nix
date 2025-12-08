{ inputs, ... }:
let
  gAttr = import ../general-attr.nix;
  certs = import ../../utils/getCerts.nix {
    service = "syncthing";
    host = "laptop";
  };
in
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.users.zerok.imports = [
        ../../home-manager
        ./output-sway-rewrite.nix
      ];
    }
    gAttr.home-manager-settings
    ./hardware-configuration.nix
    ./postgres.nix
  ]
  ++ gAttr.general-path;
}
