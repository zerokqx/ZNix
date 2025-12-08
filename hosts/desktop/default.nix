{ inputs, ... }:
let
  gAttr = import ../general-attr.nix;
in
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [

    inputs.stylix.nixosModules.stylix
    inputs.home-manager.nixosModules.home-manager
    { home-manager.users.zerok.imports = [ ../../home-manager ]; }
    {

      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "backup";
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    }
    ./hardware-configuration.nix
    ./pkgs.nix
  ]
  ++ gAttr.general-path;
}
