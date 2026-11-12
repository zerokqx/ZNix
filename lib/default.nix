inputs: {
  mkHost =
    { system, modules }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [ ../configuration.nix ] ++ modules;
    };

  mkHome =
    { system, module }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.config = import ./package-policy.nix; }
      ]
      ++ (import ./home-modules.nix inputs)
      ++ [ module ];
    };
}
