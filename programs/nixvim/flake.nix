{
  description = "NixVim";

  inputs = {
    nixpkgs.follows = "nixvim/nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs =
    { nixpkgs, nixvim, ... }:
    let
      system = "x86_64-linux";
      keymaps = import ./keymaps.nix;

      pkgs = import nixpkgs { inherit system; };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in

    {

      packages = forAllSystems (
        system:
        let
          nixvim' = nixvim.legacyPackages.${system};
          nvim = nixvim'.makeNixvimWithModule {
            pkgs = import nixpkgs { inherit system; };
            module = {
              imports = [
                ./plugins
                ./keymaps.nix
                ./opts.nix
              ];

              waylandSupport = true;
              globals = {
                mapleader = " ";
                formaters = {
                  typescript = [ "prettier" ];
                };
              };
            };
          };
        in
        {
          inherit nvim;
          default = nvim;
        }
      );
    };
}
