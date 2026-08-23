{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      desktop = import ./desktop { inherit inputs; };
      laptop = import ./laptop { inherit inputs; };
    };

    homeConfigurations = {
      "zerok" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.permittedInsecurePackages = [
              "beekeeper-studio-5.3.4"
              "nodejs-slim-20.20.2"
            ];
          }
          inputs.stylix.homeModules.stylix
          inputs.dms.homeModules.dank-material-shell
          inputs.dms-plugin-registry.homeModules.default
          inputs.noctalia.homeModules.default
          inputs.nixvim.homeModules.nixvim
          ../home/zerokqx
        ];
      };
      "zerokqx" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.permittedInsecurePackages = [
              "beekeeper-studio-5.3.4"
              "nodejs-slim-20.20.2"
            ];
          }
          inputs.stylix.homeModules.stylix
          inputs.dms.homeModules.dank-material-shell
          inputs.dms-plugin-registry.homeModules.default
          inputs.noctalia.homeModules.default
          inputs.nixvim.homeModules.nixvim
          ../home/zerokqx
        ];
      };
    };
  };
}
