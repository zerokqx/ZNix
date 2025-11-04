{
  description = "flake-parts configuration for NixOS";

  inputs = {
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    znvim.url = "path:./programs/nvim";
  };

  outputs = inputs@{ flake-parts, nixpkgs, znvim, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      default = import ./dev-shells { inherit pkgs; };
    in flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ system ];
      imports = [
        home-manager.flakeModules.home-manager

        ./hosts
      ];
      flake = { devShells.${system} = { inherit default; }; };
    };
}
