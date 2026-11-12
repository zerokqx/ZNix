{
  description = "ZNix NixOS and Home Manager configurations";

  inputs = {
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";

    # vkpl = {
    #   url = "github:zerokqx/vkpl";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    lu.url = "github:zerokqx/lu";
    lu.inputs.nixpkgs.follows = "nixpkgs";
    bundlers.url = "github:ralismark/nix-appimage";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-preview-share-picker = {
      url = "git+https://github.com/WhySoBad/hyprland-preview-share-picker?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
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
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
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

          menuPkg = pkgs.callPackage ./pkgs/znix-menu.nix { };
        in
        {
          formatter = pkgs.nixfmt;
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              bash
              git
              jq
              python3
              shellcheck
              nixfmt
              cargo
              rustc
            ];
          };

          checks = {
            configurations = import ./tests/configurations.nix {
              inherit inputs pkgs;
              inherit (inputs.self) nixosConfigurations homeConfigurations;
            };
            menu = menuPkg;
            workflow =
              pkgs.runCommand "znix-workflow"
                {
                  nativeBuildInputs = with pkgs; [
                    bash
                    git
                    python3
                    shellcheck
                  ];
                }
                ''
                  cp -r ${./scripts} scripts
                  cp -r ${./tests} tests
                  shellcheck scripts/*.sh
                  python3 -B -m unittest discover -s tests
                  touch "$out"
                '';
          };

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
