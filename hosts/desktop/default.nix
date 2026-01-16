{ inputs, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ../../configuration.nix

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.users.zerok.imports = [

        ../../home

        inputs.nixvim.homeManagerModules.nixvim
        inputs.stylix.homeModules.stylix
        inputs.noctalia.homeModules.default
      ];
    }
    ./hardware-configuration.nix
  ];
}
