{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = import ../home/zerokqx/nixvim/config.nix;
      };
      app = {
        program = "${nvim}/bin/nvim";
        meta.description = "Neovim with the ZNix Nixvim configuration";
      };
    in
    {
      packages = {
        nixvim = nvim;
        default = nvim;
      };
      apps = {
        nixvim = app;
        default = app;
      };
    };
}
