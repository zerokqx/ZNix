{
  outputs =
    {
      nixpkgs,
      nixvim,
      self,
      ...
    }:
    let

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
            extraSpecialArgs = {
              icons = import ./utils/icons.nix;
            };
            pkgs = import nixpkgs { inherit system; };
            module = {

              imports = [
                {
                  _module.args = {
                    inherit self;
                  };
                }
                ./options.nix
                ./languages
                ./plugins
                ./keymaps.nix
                ./opts.nix
              ];

              animations = true;
              fileManager = "snacks";
              waylandSupport = true;
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
