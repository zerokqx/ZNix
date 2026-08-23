{ inputs, lib, ... }:
let
  hostsDir = ./.;
  entries = builtins.readDir hostsDir;
  hostNames = builtins.filter (
    name: entries.${name} == "directory" && builtins.pathExists (hostsDir + "/${name}/default.nix")
  ) (builtins.attrNames entries);

  nixosConfigs = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = import (hostsDir + "/${name}") { inherit inputs; };
    }) hostNames
  );

  homeDir = ../home;
  homeEntries = builtins.readDir homeDir;
  homeNames = builtins.filter (
    name: homeEntries.${name} == "directory" && builtins.pathExists (homeDir + "/${name}/default.nix")
  ) (builtins.attrNames homeEntries);

  homeConfigs = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = inputs.home-manager.lib.homeManagerConfiguration {
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
          (homeDir + "/${name}")
        ];
      };
    }) homeNames
  );
in
{
  flake = {
    nixosConfigurations = nixosConfigs;
    homeConfigurations = homeConfigs // {
      "zerok" = homeConfigs."zerokqx" or homeConfigs."noop";
    };
  };
}
