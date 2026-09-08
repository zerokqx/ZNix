{
  description = "flake-parts configuration for NixOS";

  inputs = {
    lu.url = "github:zerokqx/lu";
    lu.inputs.nixpkgs.follows = "nixpkgs";
    bundlers.url = "github:ralismark/nix-appimage";
    hyprland.url = "github:hyprwm/Hyprland";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";

  };

  outputs =
    inputs@{
      flake-parts,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        home-manager.flakeModules.home-manager
        ./hosts
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module = import ./home/zerokqx/nixvim/config.nix;
          };

          menuPkg = pkgs.rustPlatform.buildRustPackage {
            pname = "znix-menu";
            version = "0.1.0";
            src = ./rust/znix-menu;
            cargoLock.lockFile = ./rust/znix-menu/Cargo.lock;
          };
        in
        {
          packages = {
            nixvim = nvim;
            menu = menuPkg;
            default = nvim;
          };
          apps = {
            default = {
              type = "app";
              program = "${nvim}/bin/nvim";
            };
            nixvim = {
              type = "app";
              program = "${nvim}/bin/nvim";
            };
            menu = {
              type = "app";
              program = "${menuPkg}/bin/znix-menu";
            };
          };
        };
    };
}
