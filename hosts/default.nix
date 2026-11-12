{ inputs, ... }:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  mkHome =
    module:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.config = import ../lib/package-policy.nix; }
      ]
      ++ (import ../lib/home-modules.nix inputs)
      ++ [ module ];
    };

  zerokqx = mkHome ../home/zerokqx;
in
{
  flake = {
    nixosConfigurations = {
      desktop = nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./desktop ];
      };
      laptop = nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./laptop ];
      };
      noop = nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./noop ];
      };
    };

    homeConfigurations = {
      inherit zerokqx;
      noop = mkHome ../home/noop;
      zerok = zerokqx;
    };
  };
}
