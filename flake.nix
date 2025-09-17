{
  description = "flake-parts configuration for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, nixpkgs, sops-nix, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      default = import ./dev-shells { inherit pkgs; };
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ system ];
      imports = [
        home-manager.flakeModules.home-manager
        ./nixos.nix
        sops-nix.nixosModules.sops
      ];
      flake = { devShells.${system} = { inherit default; }; };
    };
}
