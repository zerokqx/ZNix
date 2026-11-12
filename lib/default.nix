inputs: {
  mkHost =
    { system, modules }:
    let
      inherit (inputs.nixpkgs.lib) assertMsg mkOptionDefault nixosSystem;
      host = nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ../configuration.nix
          # Keep the hardware setting visible for the check below.
          { nixpkgs.hostPlatform = mkOptionDefault system; }
        ]
        ++ modules;
      };
      hostPlatform = host.config.nixpkgs.hostPlatform.system;
    in
    assert assertMsg (hostPlatform == system)
      "ZNix host ${host.config.networking.hostName} uses nixpkgs.hostPlatform ${hostPlatform}, but the registry declares ${system}";
    host;

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
