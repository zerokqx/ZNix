{
  description = "flake-parts configuration for NixOS";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    # stylix.url = "github:nix-community/stylix/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    znvim = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "path:./programs/nixvim";
    };

    rofishot = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "path:./programs/rofishot";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      default = import ./dev-shells { inherit pkgs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ system ];

      imports = [
        home-manager.flakeModules.home-manager

        ./hosts
      ];
      flake = {
        devShells.${system} = { inherit default; };
      };
    };
}
