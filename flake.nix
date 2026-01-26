{
  description = "flake-parts configuration for NixOS";

  inputs = {
    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";

  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      firefox,
      nixvim,
      spicetify-nix,
      ...
    }:
    let

      system = "x86_64-linux";

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ system ];

      imports = [
        home-manager.flakeModules.home-manager
        ./hosts
      ];

    };
}
